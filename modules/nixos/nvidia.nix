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
# - GBM_BACKEND / __GLX_VENDOR_LIBRARY_NAME: the nixpkgs Brave wrapper puts
#   mesa-24.x/lib in LD_LIBRARY_PATH. Mesa's GBM backend doesn't know NV12 format
#   (used by the Chromium GPU process for VA-API decode), so it logs
#   "gbm_drv_common: Unknown or not supported format: NV12" and the GPU subprocess
#   hits a CHECK() → SIGTRAP. Forcing GBM_BACKEND=nvidia-drm makes the GPU process
#   use NVIDIA's GBM backend (/run/opengl-driver/lib/gbm/nvidia-drm_gbm.so).
#   __GLX_VENDOR_LIBRARY_NAME=nvidia ensures libglvnd routes GLX to the NVIDIA vendor.
# - __EGL_VENDOR_LIBRARY_DIRS: belt-and-suspenders for EGL vendor discovery — points
#   libglvnd at /run/opengl-driver/share/glvnd/egl_vendor.d in contexts where
#   the wrapper's isolated libglvnd would otherwise find nothing.
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

    # Make VA-API and GPU vendor libs discoverable system-wide (not just inside Hyprland).
    # These must be in sessionVariables (written to /etc/pam/environment, loaded at login)
    # to apply in all contexts: terminal, GDM, D-Bus app menu, Hyprland children.
    # Setting only in Hyprland's env block leaves GDM/D-Bus launches without them.
    environment.sessionVariables = {
      LIBVA_DRIVER_NAME  = "nvidia";
      LIBVA_DRIVERS_PATH = "/run/opengl-driver/lib/dri";
      # Force NVIDIA GBM backend. Mesa's GBM (injected via LD_LIBRARY_PATH by the
      # nixpkgs Brave wrapper) rejects NV12 format → GPU subprocess CHECK() → SIGTRAP.
      GBM_BACKEND               = "nvidia-drm";
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      # Belt-and-suspenders: point libglvnd EGL vendor discovery at the system configs.
      __EGL_VENDOR_LIBRARY_DIRS = "/run/opengl-driver/share/glvnd/egl_vendor.d";
    };

    environment.systemPackages = with pkgs; [
      libva-utils  # provides vainfo for verifying VA-API after rebuild
    ];
  };
}
