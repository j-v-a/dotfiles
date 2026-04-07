# modules/lib/nixos-host.nix
# Flake-parts module: exports flake.lib.loadNixosAndHmModuleForUser.
#
# Assembles a NixOS system config from a feature list.
# Each feature name is looked up in both:
#   - config.flake.modules.nixos.<feature>        (NixOS system module, may be absent)
#   - config.flake.modules.homeManager.<feature>  (HM user module, may be absent)
# A feature absent from BOTH namespaces is a hard error at eval time (typo guard).
#
# Usage (from a host module):
#   flake.nixosConfigurations.missandei =
#     config.flake.lib.loadNixosAndHmModuleForUser config {
#       hostname = "missandei";
#       system   = "x86_64-linux";
#       username = "jasper";
#       features = [ "base" "users" "hyprland" "dev" "gaming" "nvidia" "shell"
#                    "cli-tools" "git" "editors" "linux-toolchains" ];
#       extraNixosModules = [ ./hardware/missandei.nix ];
#     };
{ inputs, config, ... }:

{
  flake.lib.loadNixosAndHmModuleForUser =
    cfg:
    { hostname, system, username, features, extraNixosModules ? [] }:
    let
      nixpkgs = inputs.nixpkgs;

      # Validate every feature name: throw at eval time if unrecognised in both namespaces.
      validateFeature = f:
        if cfg.flake.modules.nixos ? ${f} || cfg.flake.modules.homeManager ? ${f}
        then f
        else throw "dotfiles: unknown feature \"${f}\" — not found in nixos.* or homeManager.*";

      validatedFeatures = map validateFeature features;
      nixosModules      = map (f: cfg.flake.modules.nixos.${f}       or {}) validatedFeatures;
      hmModules         = map (f: cfg.flake.modules.homeManager.${f} or {}) validatedFeatures;
    in
    nixpkgs.lib.nixosSystem {
      inherit system;
      # username is passed so NixOS feature modules (e.g. users.nix, virt.nix) can
      # reference the user without hardcoding a name.
      specialArgs = { inherit inputs username; inherit (inputs) nixos-hardware sops-nix; };
      modules = nixosModules ++ extraNixosModules ++ [
        inputs.sops-nix.nixosModules.sops
        inputs.home-manager.nixosModules.home-manager
        {
          networking.hostName = hostname;

          # Use the same nixpkgs instance as NixOS (no separate pkgs eval).
          home-manager.useGlobalPkgs   = true;
          # Install user packages into /etc/profiles, not ~/.nix-profile.
          # Required for Fish/Starship to land on the system PATH correctly under NixOS.
          home-manager.useUserPackages = true;

          # Pass username + homeDirectory so HM feature modules can reference them
          # without hardcoding a specific user.
          home-manager.extraSpecialArgs = {
            inherit username;
            homeDirectory = "/home/${username}";
            inherit (inputs) wallpapers;
          };

          home-manager.users.${username}.imports = [
            ({ osConfig, ... }: { home.stateVersion = osConfig.system.stateVersion; })
            # catppuccin/nix HM module — makes catppuccin.* options available in every
            # feature module. Opt in per-host via the "catppuccin" feature.
            inputs.catppuccin.homeManagerModules.catppuccin
          ] ++ hmModules;
        }
      ];
    };
}
