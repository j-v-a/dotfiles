# modules/nixos/hyprland.nix
# Hyprland WM — system-level enablement.
# User config (keybinds, rules, look) is in modules/home/hyprland.nix; the shell
# (bar, notifications, lock, idle, wallpaper) is Noctalia (home/noctalia.nix).
#
# Display manager note: this module no longer sets a display manager.
# When gnome.nix is in the feature list, GDM is used and Hyprland appears as
# a selectable session. When gnome.nix is absent, SDDM can be enabled separately
# or added back here. For Missandei, gnome.nix handles the DM.
_:

{
  flake.modules.nixos.hyprland = { pkgs, ... }: {
    programs.hyprland = {
      enable = true;
      xwayland.enable = true;
      # Run Hyprland as a systemd session (UWSM): proper graphical-session.target ordering
      # for the Noctalia/Walker user services. GDM shows "Hyprland (uwsm-managed)".
      withUWSM = true;
    };

    # Screen lock + idle are Noctalia's (home/noctalia.nix). Its lock screen authenticates
    # via the stock `login` PAM service, so no extra /etc/pam.d entry is needed.

    # XDG portal for Wayland (needed for screen sharing, file pickers, etc.)
    # xdg-desktop-portal-gtk is added by gnome.nix when GNOME coexists.
    xdg.portal = {
      enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
      # Per-desktop portal routing (key = lowercased XDG_CURRENT_DESKTOP), so GNOME and
      # Hyprland each get their own backend for screencast/file picker.
      config.hyprland.default = [
        "hyprland"
        "gtk"
      ];
    };

    # Audio — pipewire
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      wireplumber.enable = true;
    };
    security.rtkit.enable = true; # needed for pipewire real-time scheduling
  };
}
