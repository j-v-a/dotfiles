# modules/homelab/network.nix
# WireGuard (remote LAN access) + Caddy (local reverse proxy) + AdGuard Home (DNS sinkhole).
# Populated in Phase 4.
{ config, ... }:

{
  # AdGuard Home — DNS sinkhole + DoH upstream
  services.adguardhome = {
    enable = true;
    # settings configured via web UI initially, then migrated to declarative config
  };

  # WireGuard — remote LAN access
  # Private key managed via sops-nix
  # networking.wireguard.interfaces.wg0 = {
  #   ips = [ "10.100.0.1/24" ];
  #   listenPort = 51820;
  #   privateKeyFile = config.sops.secrets.wg-private-key.path;
  #   peers = [];  # add client peers here
  # };

  # Caddy — local reverse proxy with local CA (tls internal)
  # services.caddy = { ... };  # populate in Phase 4

  # Open WireGuard port
  # networking.firewall.allowedUDPPorts = [ 51820 ];
}
