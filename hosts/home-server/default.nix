# hosts/home-server/default.nix
# Home server minipc — NixOS + incus. Configured in Phase 4.
{ ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/homelab
  ];

  networking.hostName = "home-server";

  nixpkgs.config.allowUnfreePredicate = _: true;

  # ZFS — recommended for homelab storage integrity + snapshots
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.forceImportRoot = false;

  # Set at install time — NEVER change after first boot
  system.stateVersion = "24.11";
}
