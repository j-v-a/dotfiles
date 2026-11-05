# modules/nixos/logitech.nix
# Logitech MX device support — Solaar for button/DPI/flow configuration via Unifying/Bolt receiver.
_:

{
  flake.modules.nixos.logitech = _: {
    # Solaar — GUI manager for Logitech devices (button remapping, DPI, per-app profiles).
    # enableGraphical installs solaar; enable installs udev rules for non-root receiver access.
    hardware.logitech.wireless = {
      enable = true; # udev rules for Unifying/Bolt receivers
      enableGraphical = true; # pulls in solaar GUI
    };
  };
}
