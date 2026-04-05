# modules/nixos/hyprland.nix
# Hyprland WM — system-level enablement.
# User config (keybinds, rules, waybar, rofi) is in modules/home/hyprland.nix.
{ ... }:

{
  flake.modules.nixos.hyprland = { pkgs, ... }: {
    programs.hyprland = {
      enable          = true;
      xwayland.enable = true;
    };

    # Display manager: SDDM with Wayland session
    services.displayManager.sddm = {
      enable         = true;
      wayland.enable = true;
    };

    # XDG portal for Wayland (needed for screen sharing, file pickers, etc.)
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
