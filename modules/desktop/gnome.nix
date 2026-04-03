# modules/desktop/gnome.nix
# GNOME desktop — system-level config for the Surface.
{ pkgs, ... }:

{
  services.xserver = {
    enable = true;
    desktopManager.gnome.enable = true;
  };
  services.displayManager.gdm = {
    enable = true;
    wayland = true;  # GNOME on Wayland
  };

  # Audio
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };
  security.rtkit.enable = true;

  # Remove GNOME bloat
  environment.gnome.excludePackages = with pkgs; [
    gnome-tour
    gnome-contacts
    gnome-maps
    gnome-music
    gnome-weather
    totem   # video player
    epiphany  # GNOME web browser
  ];
}
