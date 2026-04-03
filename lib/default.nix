# lib/default.nix
# Shared helper functions for building host configurations.
{ lib }:

{
  # Build a NixOS host configuration.
  # Used for personal-workstation, surface, home-server.
  mkNixosHost = { inputs, nixos-hardware, sops-nix, hostname, system, nixpkgsChannel ? null, ... }:
    let
      pkgs-nixos = import (builtins.fetchTarball {
        url = "https://github.com/NixOS/nixpkgs/archive/nixos-24.11.tar.gz";
      }) { inherit system; config.allowUnfreePredicate = _: true; };
    in
    inputs.nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit inputs nixos-hardware sops-nix; };
      modules = [
        sops-nix.nixosModules.sops
        ./hosts/${hostname}/default.nix
      ];
    };
}
