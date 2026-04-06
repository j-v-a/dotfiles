# modules/nixos/nvidia.nix
# Nvidia GPU driver configuration — GTX 1060 (Pascal).
#
# GTX 1060 (Pascal) confirmed NOT on Nvidia legacy list → use nvidiaPackages.stable.
# If ever upgrading GPU, recheck: https://www.nvidia.com/en-us/drivers/unix/legacy-gpu/
#
# - open = false  REQUIRED for Pascal; open kernel module only supports Turing+
# - modesetting   REQUIRED for Hyprland / Wayland
# - hardware.graphics replaces hardware.opengl (renamed in NixOS 24.11)
# - nvidia-vaapi-driver in extraPackages: required for Chromium VA-API (VaapiVideoDecoder
#   feature flag injected by the nixpkgs Brave/Chrome wrapper). Without it the GPU
#   process hits a SIGTRAP crash immediately on launch.
#   Verify after rebuild: vainfo --display drm --device /dev/dri/renderD128
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

    hardware.graphics = {
      enable      = true;
      enable32Bit = true;  # needed for Steam + 32-bit games
      extraPackages = with pkgs; [
        nvidia-vaapi-driver  # VA-API via NVDEC; required for Brave/Chrome GPU process
        libva                # VA-API runtime
      ];
    };

    services.xserver.videoDrivers = [ "nvidia" ];
  };
}
