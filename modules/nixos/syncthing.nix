# modules/nixos/syncthing.nix
# Syncthing file sync, running as the primary user.
_:

{
  flake.modules.nixos.syncthing =
    {
      config,
      lib,
      username,
      ...
    }:
    let
      hasSecrets = builtins.pathExists ../../secrets/${config.networking.hostName}.yaml;
    in
    {
      # Web UI at http://localhost:8384 — loopback only, not LAN-exposed.
      # Device pairing is done manually in the web UI after first boot.
      # GUI password: sops secret `syncthing-gui-password` (plaintext; the init service
      # bcrypt-hashes it and PATCHes it into the config). Only active once
      # secrets/<hostname>.yaml exists — until then the web UI password stays as set there.
      sops.secrets.syncthing-gui-password = lib.mkIf hasSecrets { owner = username; };
      services.syncthing = lib.mkMerge [
        (lib.mkIf hasSecrets {
          guiPasswordFile = config.sops.secrets.syncthing-gui-password.path;
          settings.gui.user = username;
        })
        {
          enable = true;
          user = username;
          dataDir = "/home/${username}";
          configDir = "/home/${username}/.config/syncthing";
          # Opens 22000/tcp+udp (sync) and 21027/udp (local discovery); GUI stays loopback.
          openDefaultPorts = true;
          # Devices/folders are paired in the web UI, not declared here. The module's defaults
          # (override = true) deleted UI-paired devices on every restart ("Deleting stale device").
          overrideDevices = false;
          overrideFolders = false;
          settings.gui.address = "127.0.0.1:8384";
        }
      ];
    };
}
