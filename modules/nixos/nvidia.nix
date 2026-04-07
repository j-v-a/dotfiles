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
# - __EGL_VENDOR_LIBRARY_DIRS: the nixpkgs Brave wrapper ships its own libglvnd which
#   has no glvnd/egl_vendor.d of its own. Without this var, libglvnd cannot discover
#   the NVIDIA/Mesa EGL vendor JSON files, EGL init fails, and the Chromium GPU process
#   hits a CHECK() → SIGTRAP. Setting this system-wide points libglvnd at the correct
#   vendor configs in all contexts (terminal, GDM, app menu, etc.).
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

    # Make VA-API driver discoverable system-wide (not just inside Hyprland).
    # Without these, libva cannot locate nvidia_drv_video.so and the Chromium/Brave
    # GPU process hits a SIGTRAP before any per-process flag processing occurs.
    environment.sessionVariables = {
      LIBVA_DRIVER_NAME  = "nvidia";
      LIBVA_DRIVERS_PATH = "/run/opengl-driver/lib/dri";
      # Point libglvnd at the system EGL vendor JSON files. The nixpkgs Brave/Chrome
      # wrapper ships its own isolated libglvnd with no egl_vendor.d of its own;
      # without this var it cannot discover NVIDIA/Mesa EGL drivers and the GPU
      # subprocess hits a CHECK() → SIGTRAP on launch.
      __EGL_VENDOR_LIBRARY_DIRS = "/run/opengl-driver/share/glvnd/egl_vendor.d";
    };

    environment.systemPackages = with pkgs; [
      libva-utils  # provides vainfo for verifying VA-API after rebuild
    ];
  };
}
