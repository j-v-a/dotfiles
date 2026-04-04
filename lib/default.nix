# lib/default.nix
# Shared helper functions for building host configurations.
{ lib }:

let
  # Absolute path to the flake root — lib/ is one level below it.
  root = ../.;
in
{
  # Build a NixOS host configuration.
  # Used for personal-workstation, surface, home-server.
  #
  # Callers MUST pass nixpkgs = nixpkgs-linux (nixos-24.11) — NOT the Darwin nixpkgs.
  # home-manager is wired in here as a NixOS module so we don't need a separate
  # homeManagerConfigurations output; NixOS rebuilds both system + home in one pass.
  mkNixosHost = { inputs, nixpkgs, nixos-hardware, sops-nix, home-manager, hostname, system, ... }:
    nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit inputs nixos-hardware sops-nix; };
      modules = [
        sops-nix.nixosModules.sops
        home-manager.nixosModules.home-manager
        {
          # home-manager: use the same nixpkgs instance as NixOS (no separate pkgs eval)
          home-manager.useGlobalPkgs = true;
          # home-manager: install user packages into /etc/profiles, not ~/.nix-profile
          # Required for Fish/Starship to land on the system PATH correctly under NixOS.
          home-manager.useUserPackages = true;
        }
        "${root}/hosts/${hostname}/default.nix"
      ];
    };
}
