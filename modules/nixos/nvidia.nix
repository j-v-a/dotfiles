# modules/nixos/nvidia.nix
# Nvidia GPU driver configuration — GTX 1060 (Pascal).
#
# GTX 1060 (Pascal) confirmed NOT on Nvidia legacy list → use nvidiaPackages.stable.
# If ever upgrading GPU, recheck: https://www.nvidia.com/en-us/drivers/unix/legacy-gpu/
#
# - open = false  REQUIRED for Pascal; open kernel module only supports Turing+
# - modesetting   REQUIRED for Hyprland / Wayland
# - hardware.graphics replaces hardware.opengl (renamed in NixOS 24.11)
# - nvidia-vaapi-driver in extraPackages: enables hardware video decode (VA-API via NVDEC)
#   for apps like mpv, VLC, etc. Verify: vainfo --display drm --device /dev/dri/renderD128
# - LIBVA_* in sessionVariables: system-wide so VA-API works in all contexts (terminal,
#   GDM, D-Bus app menu, Hyprland children). Hyprland env block alone is insufficient.
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
        nvidia-vaapi-driver  # VA-API via NVDEC for hardware video decode
        libva                # VA-API runtime
      ];
    };

    services.xserver.videoDrivers = [ "nvidia" ];

    # Make VA-API libs discoverable system-wide (not just inside Hyprland).
    # Written to /etc/environment via PAM — applies at login in all contexts.
    environment.sessionVariables = {
      LIBVA_DRIVER_NAME  = "nvidia";
      LIBVA_DRIVERS_PATH = "/run/opengl-driver/lib/dri";
    };

    environment.systemPackages = with pkgs; [
      libva-utils  # provides vainfo for verifying VA-API after rebuild
    ];
  };
}
