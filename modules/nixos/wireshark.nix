# modules/nixos/wireshark.nix
# Wireshark — packet analyser.
# The GUI package is installed via home/desktop-apps.nix.
# The wireshark group is assigned in nixos/users.nix.
{ ... }:

{
  flake.modules.nixos.wireshark = { ... }: {
    # Enables setcap permissions for non-root packet capture.
    programs.wireshark.enable = true;
  };
}
