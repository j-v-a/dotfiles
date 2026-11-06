# modules/lib/nixos-host.nix
# Flake-parts module: exports flake.lib.loadNixosAndHmModuleForUser.
#
# Assembles a NixOS system config from a feature list.
# Each feature name is looked up in both:
#   - config.flake.modules.nixos.<feature>        (NixOS system module, may be absent)
#   - config.flake.modules.homeManager.<feature>  (HM user module, may be absent)
# A feature absent from BOTH namespaces is a hard error at eval time (typo guard).
#
# Profiles bundle features: `profiles = [ "workstation" ]` expands to the feature list in
# `profileFeatures` below (prepended, de-duplicated) before validation. Unknown profile
# names are a hard error too. The expanded list is passed to modules as `features`.
#
# Usage (from a host module):
#   flake.nixosConfigurations.missandei =
#     config.flake.lib.loadNixosAndHmModuleForUser config {
#       hostname = "missandei";
#       system   = "x86_64-linux";
#       username = "jasper";
#       profiles = [ "workstation" ];
#       features = [ "hyprland" "dev" "gaming" "nvidia" "shell"
#                    "cli-tools" "git" "editors" "linux-toolchains" ];
#       extraNixosModules = [ ../_hardware/missandei.nix ];
#     };
{ inputs, ... }:

{
  flake.lib.loadNixosAndHmModuleForUser =
    cfg:
    {
      hostname,
      system,
      username,
      profiles ? [ ],
      features ? [ ],
      extraNixosModules ? [ ],
    }:
    let
      inherit (inputs) nixpkgs;

      # Profile name → feature bundle. Add profile-server / profile-tablet here when the
      # first such host lands (Phase C/D).
      profileFeatures = {
        # Desktop machine with a human user: base system + account, containers, file sync,
        # Bluetooth, system-level Firefox Developer Edition.
        workstation = [
          "base"
          "docker"
          "syncthing"
          "bluetooth"
          "firefox-devedition"
          "users"
        ];
      };

      expandProfile =
        p:
        profileFeatures.${p}
          or (throw "dotfiles: unknown profile \"${p}\" — known: ${toString (builtins.attrNames profileFeatures)}");

      allFeatures = nixpkgs.lib.unique (builtins.concatMap expandProfile profiles ++ features);

      # Validate every feature name: throw at eval time if unrecognised in both namespaces.
      validateFeature =
        f:
        if cfg.flake.modules.nixos ? ${f} || cfg.flake.modules.homeManager ? ${f} then
          f
        else
          throw "dotfiles: unknown feature \"${f}\" — not found in nixos.* or homeManager.*";

      validatedFeatures = map validateFeature allFeatures;
      nixosModules = map (f: cfg.flake.modules.nixos.${f} or { }) validatedFeatures;
      hmModules = map (f: cfg.flake.modules.homeManager.${f} or { }) validatedFeatures;
    in
    nixpkgs.lib.nixosSystem {
      inherit system;
      # username is passed so NixOS feature modules (e.g. users.nix, virt.nix) can
      # reference the user without hardcoding a name.
      specialArgs = {
        inherit inputs username;
        inherit (inputs) nixos-hardware sops-nix;
        features = validatedFeatures;
      };
      modules =
        nixosModules
        ++ extraNixosModules
        ++ [
          inputs.sops-nix.nixosModules.sops
          inputs.home-manager.nixosModules.home-manager
          {
            networking.hostName = hostname;

            # Wire NUR in as a nixpkgs overlay so pkgs.nur is available in all modules.
            nixpkgs.overlays = [ inputs.nur.overlays.default ];

            # Use the same nixpkgs instance as NixOS (no separate pkgs eval).
            home-manager.useGlobalPkgs = true;
            # Install user packages into /etc/profiles, not ~/.nix-profile.
            # Required for Fish/Starship to land on the system PATH correctly under NixOS.
            home-manager.useUserPackages = true;
            # Back up existing files that conflict with HM-managed symlinks.
            home-manager.backupFileExtension = "hm-backup";

            # Pass username + homeDirectory so HM feature modules can reference them
            # without hardcoding a specific user.
            home-manager.extraSpecialArgs = {
              inherit username;
              homeDirectory = "/home/${username}";
              inherit (inputs) wallpapers;
            };

            home-manager.users.${username}.imports = [
              (
                { osConfig, ... }:
                {
                  home.stateVersion = osConfig.system.stateVersion;
                  home.username = username;
                  home.homeDirectory = "/home/${username}";
                }
              )
              # catppuccin/nix HM module — makes catppuccin.* options available in every
              # feature module. Opt in per-host via the "catppuccin" feature.
              inputs.catppuccin.homeModules.catppuccin
            ]
            ++ hmModules;
          }
        ];
    };
}
