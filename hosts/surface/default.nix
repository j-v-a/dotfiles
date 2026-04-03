# hosts/surface/default.nix
# MS Surface Pro 7+ — i5-1135G7, 16GB, 256GB. GNOME + touch. Configured in Phase 3.
{ inputs, nixos-hardware, ... }:

{
  imports = [
    nixos-hardware.nixosModules.microsoft-surface-pro-intel  # linux-surface kernel + iptsd
    ./hardware-configuration.nix
    ../../modules/dev
    ../../modules/desktop/gnome.nix
  ];

  networking.hostName = "surface";

  # WiFi firmware (Marvell AVASTAR chip on Surface Pro 7+)
  hardware.enableRedistributableFirmware = true;

  # CRITICAL: Disable TLP — causes suspend/touch failures on Surface
  services.tlp.enable = false;

  # CRITICAL: Disable libcamera — camera does not work on Surface Pro 7+.
  # Without this, wireplumber fails to start and audio breaks entirely.
  services.pipewire.wireplumber.extraConfig = {
    "50-surface-disable-libcamera.conf" = {
      "monitor.libcamera" = { enabled = false; };
    };
  };

  nixpkgs.config.allowUnfreePredicate = _: true;

  # Set at install time — NEVER change after first boot
  system.stateVersion = "24.11";
}
