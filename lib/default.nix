# lib/default.nix
# Shared helper functions for building host configurations.
{ lib }:

{
  # Build a NixOS host configuration.
  # Used for personal-workstation, surface, home-server.
  # NOTE: NixOS hosts should use nixos-24.11 nixpkgs. The private flake for each
  # NixOS device should define its own nixpkgs input pointing to nixos-24.11 and
  # pass it in via inputs. For now (Phase 1 placeholders) we accept inputs.nixpkgs.
  mkNixosHost = { inputs, nixos-hardware, sops-nix, hostname, system, ... }:
    inputs.nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit inputs nixos-hardware sops-nix; };
      modules = [
        sops-nix.nixosModules.sops
        ./hosts/${hostname}/default.nix
      ];
    };
}
