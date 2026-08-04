# modules/nixos/logitech.nix
# Logitech MX device support — Solaar for button/DPI/flow configuration via Unifying/Bolt receiver.
{ ... }:

{
  flake.modules.nixos.logitech = { pkgs, ... }: {
    # Solaar — GUI manager for Logitech devices (button remapping, DPI, per-app profiles).
    # Also installs the required udev rules for non-root access to receivers.
    environment.systemPackages = [ pkgs.solaar ];
    hardware.logitech.wireless = {
      enable       = true;   # udev rules for Unifying/Bolt receivers
      enableGraphical = true;  # pulls in solaar GUI
    };
  };
}
