# modules/nixos/syncthing.nix
# Syncthing file sync, running as the primary user.
_:

{
  flake.modules.nixos.syncthing = { username, ... }: {
    # Web UI at http://localhost:8384 — loopback only, not LAN-exposed.
    # Device pairing is done manually in the web UI after first boot.
    # NOTE: set a GUI password in the web UI — Nix cannot manage the hashed password
    # declaratively without storing secrets in the Nix store.
    services.syncthing = {
      enable = true;
      user = username;
      dataDir = "/home/${username}";
      configDir = "/home/${username}/.config/syncthing";
      # Opens 22000/tcp+udp (sync) and 21027/udp (local discovery); GUI stays loopback.
      openDefaultPorts = true;
      settings.gui.address = "127.0.0.1:8384";
    };
  };
}
