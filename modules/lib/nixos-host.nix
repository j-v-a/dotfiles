# modules/_lib/nixos-host.nix
# Flake-parts module: exports flake.lib.loadNixosAndHmModuleForUser.
#
# This helper assembles a NixOS system config from a feature list.
# Each feature name maps to:
#   - config.flake.modules.nixos.<feature>   (NixOS system module, may be absent)
#   - config.flake.modules.homeManager.<feature>  (HM user module, may be absent)
#
# Usage (from a host module):
#   flake.nixosConfigurations.missandei =
#     config.flake.lib.loadNixosAndHmModuleForUser config {
#       hostname = "missandei";
#       system   = "x86_64-linux";
#       username = "jasper";
#       features = [ "base" "hyprland" "dev" "gaming" "nvidia" "shell"
#                    "cli-tools" "git" "editors" "linux-toolchains" ];
#       extraNixosModules = [ ./hardware/missandei.nix ];
#     };
{ inputs, config, ... }:

{
  flake.lib.loadNixosAndHmModuleForUser =
    cfg:
    { hostname, system, username, features, extraNixosModules ? [] }:
    let
      nixpkgs   = inputs.nixpkgs-linux;
      nixosModules  = builtins.map (f: cfg.flake.modules.nixos.${f}          or {}) features;
      hmModules     = builtins.map (f: cfg.flake.modules.homeManager.${f}    or {}) features;
    in
    nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit inputs; inherit (inputs) nixos-hardware sops-nix; };
      modules = nixosModules ++ extraNixosModules ++ [
        inputs.sops-nix.nixosModules.sops
        inputs.home-manager.nixosModules.home-manager
        {
          networking.hostName = hostname;

          # home-manager: use the same nixpkgs instance as NixOS (no separate pkgs eval)
          home-manager.useGlobalPkgs    = true;
          # home-manager: install user packages into /etc/profiles, not ~/.nix-profile
          # Required for Fish/Starship to land on the system PATH correctly under NixOS.
          home-manager.useUserPackages  = true;

          # Pass username + homeDirectory to every HM module so feature modules
          # can reference them without hardcoding a specific user.
          home-manager.extraSpecialArgs = {
            inherit username;
            homeDirectory = "/home/${username}";
          };

          home-manager.users.${username}.imports = [
            ({ osConfig, ... }: { home.stateVersion = osConfig.system.stateVersion; })
          ] ++ hmModules;
        }
      ];
    };
}
