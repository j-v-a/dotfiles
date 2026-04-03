# modules/desktop/default.nix
# Linux desktop system-level config entry point.
{ ... }:

{
  imports = [
    ./hyprland.nix
  ];
}
