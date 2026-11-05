# modules/nixos/bluetooth.nix
# Bluetooth stack + Blueman GUI/tray applet.
_:

{
  flake.modules.nixos.bluetooth = _: {
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
    services.blueman.enable = true;
  };
}
