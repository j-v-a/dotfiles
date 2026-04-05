# modules/hosts/home-server.nix
# Home server (Proxmox → NixOS + incus) — Phase 4 (not yet configured).
# Placeholder so the flake output exists for future work.
{ config, ... }:

{
  # flake.nixosConfigurations.home-server =
  #   config.flake.lib.loadNixosAndHmModuleForUser config {
  #     hostname = "home-server";
  #     system   = "x86_64-linux";
  #     username = "jasper";
  #     features = [ "base" "shell" "cli-tools" "git" "editors" ];
  #     extraNixosModules = [ ../hardware/home-server.nix ];
  #   };
}
