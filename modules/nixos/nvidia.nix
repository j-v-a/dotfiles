# modules/nixos/nvidia.nix
# Nvidia GPU driver configuration — GTX 1060 (Pascal).
#
# GTX 1060 (Pascal) confirmed NOT on Nvidia legacy list → use nvidiaPackages.stable.
# If ever upgrading GPU, recheck: https://www.nvidia.com/en-us/drivers/unix/legacy-gpu/
#
# - open = false  REQUIRED for Pascal; open kernel module only supports Turing+
# - modesetting   REQUIRED for Hyprland / Wayland
# - hardware.graphics replaces hardware.opengl (renamed in NixOS 24.11)
{ ... }:

{
  flake.modules.nixos.nvidia = { pkgs, ... }: {
    hardware.nvidia = {
      package            = pkgs.linuxPackages.nvidiaPackages.stable;
      modesetting.enable = true;
      open               = false;
      nvidiaSettings     = true;   # installs nvidia-settings GUI
      powerManagement.enable = false;  # desktop — not a laptop
    };

    hardware.graphics.enable      = true;
    hardware.graphics.enable32Bit = true;  # needed for Steam + 32-bit games

    services.xserver.videoDrivers = [ "nvidia" ];
  };
}
