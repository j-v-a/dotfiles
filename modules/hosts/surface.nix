# modules/hosts/surface.nix
# Surface Pro 7+ — Phase 3 (not yet configured).
# Placeholder so the flake output exists for future work.
{ config, ... }:

{
  # flake.nixosConfigurations.surface =
  #   config.flake.lib.loadNixosAndHmModuleForUser config {
  #     hostname = "surface";
  #     system   = "x86_64-linux";
  #     username = "jasper";
  #     features = [ "base" "shell" "cli-tools" "git" "editors" ];
  #     extraNixosModules = [ ../hardware/surface.nix ];
  #   };
}
