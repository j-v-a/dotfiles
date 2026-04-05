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

    # GDM display manager — replaces SDDM as the session picker
    # In NixOS 24.11, GDM lives under services.xserver.displayManager.gdm
    # (not services.displayManager.gdm which does not exist).
    services.xserver.displayManager.gdm = {
      enable  = true;
      wayland = true;
    };

    # Disable SDDM — GDM and SDDM conflict; only one display manager can be active.
    # services.displayManager.sddm is the 24.11 path for the new unified DM option.
    services.displayManager.sddm.enable        = false;
    services.xserver.displayManager.sddm.enable = false;

    # GNOME keyring — unlocks on GDM login; used by apps for credential storage
    services.gnome.gnome-keyring.enable = true;

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
