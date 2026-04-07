# modules/nixos/gnome.nix
# GNOME desktop — coexists with Hyprland.
# GDM is the session picker; both GNOME and Hyprland appear as session options.
#
# Display manager note: GDM and SDDM conflict — only one can be active.
# This module enables GDM and explicitly disables SDDM (which hyprland.nix would otherwise enable).
# Hyprland remains selectable as a session in GDM's session menu.
{ ... }:

{
  flake.modules.nixos.gnome = { pkgs, ... }: {
    # GNOME desktop environment
    services.xserver.desktopManager.gnome.enable = true;

    # GDM display manager — replaces SDDM as the session picker.
    # services.displayManager.gdm is the correct path since NixOS 24.05;
    # the old services.xserver.displayManager.gdm alias was removed in 25.05.
    services.displayManager.gdm = {
      enable  = true;
      wayland = true;
    };

    # Disable SDDM — GDM and SDDM conflict; only one display manager can be active.
    services.displayManager.sddm.enable = false;

    # GNOME keyring — unlocks on GDM login; used by apps for credential storage
    services.gnome.gnome-keyring.enable = true;

    # PAM integration — auto-unlocks the keyring on GDM login so apps
    # (Brave, Chrome, etc.) don't prompt for the keyring password.
    security.pam.services.gdm.enableGnomeKeyring = true;

    # XDG portal for GNOME apps (file pickers, screen sharing, etc.)
    # xdg-desktop-portal-hyprland is added by hyprland.nix; we add the GTK/GNOME portal here.
    xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

    # Exclude GNOME apps we don't want (avoid bloat)
    environment.gnome.excludePackages = with pkgs; [
      gnome-tour
      gnome-connections
      epiphany          # GNOME browser (we use Brave)
      geary             # GNOME email (we use Thunderbird)
      totem             # GNOME video player (we use VLC/MPV)
    ];
  };
}
