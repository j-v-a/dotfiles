# modules/nixos/wireshark.nix
# Wireshark — packet analyser.
# The GUI package is installed via home/desktop-apps.nix.
# This module enables capture permissions and adds the user to the wireshark group.
{ ... }:

{
  flake.modules.nixos.wireshark = { ... }: {
    # Enable Wireshark with setcap permissions for non-root packet capture
    programs.wireshark.enable = true;

    # Add user to wireshark group (required for non-root packet capture)
    users.users.jasper.extraGroups = [ "wireshark" ];
  };
}
