# hosts/personal-workstation/default.nix
# Personal NixOS workstation — Ryzen 9 5900X, Gigabyte B550, GTX 10-series.
# Configured in Phase 2.
{ inputs, nixos-hardware, pkgs, ... }:

{
  imports = [
    nixos-hardware.nixosModules.gigabyte-b550       # B550 suspend fix + AMD microcode
    ./hardware-configuration.nix
    ../../modules/dev
    ../../modules/desktop/hyprland.nix
    ../../modules/gaming
  ];

  networking.hostName = "personal-workstation";

  # Unfree packages (Nvidia + Steam)
  nixpkgs.config.allowUnfreePredicate = _: true;

  # Nvidia — GTX 10-series (Pascal). Verify card against Nvidia legacy list first.
  # If card is on legacy list, change to: nvidiaPackages.legacy_535
  hardware.nvidia = {
    package = pkgs.linuxPackages.nvidiaPackages.stable;
    modesetting.enable = true;   # required for Hyprland/Wayland
    open = false;                # REQUIRED for Pascal — open module only supports Turing+
  };
  hardware.graphics.enable = true;       # was hardware.opengl in pre-24.11
  hardware.graphics.enable32Bit = true;  # was driSupport32Bit in pre-24.11
  services.xserver.videoDrivers = [ "nvidia" ];

  # Set at install time — NEVER change after first boot
  system.stateVersion = "24.11";

  # home-manager user config — populated in Phase 2
  # home-manager.users.jva082 = import ../../home/linux.nix;
}
