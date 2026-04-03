# modules/homelab/incus.nix
# incus container/VM host.
# IMPORTANT: networking.nftables.enable = true is required — incus will fail without it.
{ ... }:

{
  virtualisation.incus.enable = true;

  # Required for incus networking
  networking.nftables.enable = true;

  # Open firewall ports for incus bridge (DNS + DHCP for containers)
  networking.firewall.interfaces."incusbr0" = {
    allowedUDPPorts = [ 53 67 ];
    allowedTCPPorts = [ 53 ];
  };
}
