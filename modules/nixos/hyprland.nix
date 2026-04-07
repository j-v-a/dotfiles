# modules/nixos/hyprland.nix
# Hyprland WM — system-level enablement.
# User config (keybinds, rules, waybar, rofi) is in modules/home/hyprland.nix.
#
# Display manager note: this module no longer sets a display manager.
# When gnome.nix is in the feature list, GDM is used and Hyprland appears as
# a selectable session. When gnome.nix is absent, SDDM can be enabled separately
# or added back here. For Missandei, gnome.nix handles the DM.
{ ... }:

{
  flake.modules.nixos.hyprland = { pkgs, ... }: {
    programs.hyprland = {
      enable          = true;
      xwayland.enable = true;
    };

    # hyprlock must be enabled at the system level (not only in home-manager) because
    # NixOS needs to install a PAM entry (/etc/pam.d/hyprlock) for screen-unlock auth.
    # Without this, hyprlock starts but password verification always fails.
    programs.hyprlock.enable  = true;
    services.hypridle.enable  = true;

    # XDG portal for Wayland (needed for screen sharing, file pickers, etc.)
    # xdg-desktop-portal-gtk is added by gnome.nix when GNOME coexists.
    xdg.portal = {
      enable       = true;
      extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
    };

    # Audio — pipewire
    services.pipewire = {
      enable              = true;
      alsa.enable         = true;
      alsa.support32Bit   = true;
      pulse.enable        = true;
      wireplumber.enable  = true;
    };
    security.rtkit.enable = true;  # needed for pipewire real-time scheduling
  };
}
