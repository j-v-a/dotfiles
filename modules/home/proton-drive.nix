# modules/home/proton-drive.nix
# Mounts Proton Drive as a FUSE filesystem via rclone.
#
# Prerequisites (one-time, on the machine):
#   1.  rclone config  →  create a remote named "protondrive" with type "protondrive"
#       (interactive login — rclone will open a browser for Proton authentication).
#   2.  The mount point ~/ProtonDrive is created automatically by the systemd service.
#
# After activation the drive appears at ~/ProtonDrive and is browsable in Dolphin
# and any other file manager.
{ ... }:

{
  flake.modules.homeManager.proton-drive = { pkgs, username, homeDirectory, ... }: {
    home.packages = [ pkgs.rclone ];

    # Point Calibre at the library on Proton Drive.
    # Calibre reads this file on startup to find its library location.
    # NOTE: home.file is read-only (managed by Nix); Calibre's own "switch library"
    # dialog will fail to persist changes. Edit this source instead.
    home.file.".config/calibre/global.py.json".text = builtins.toJSON {
      library_path = "${homeDirectory}/ProtonDrive/Books/Calibrebibliotheek";
    };

    systemd.user.services.proton-drive-mount = {
      Unit = {
        Description = "Mount Proton Drive via rclone FUSE";
        After       = [ "network-online.target" ];
        Wants       = [ "network-online.target" ];
      };

      Service = {
        Type            = "simple";
        ExecStartPre    = "${pkgs.coreutils}/bin/mkdir -p ${homeDirectory}/ProtonDrive";
        ExecStart       = builtins.concatStringsSep " " [
          "${pkgs.rclone}/bin/rclone mount"
          "protondrive:"
          "${homeDirectory}/ProtonDrive"
          "--vfs-cache-mode full"
          "--vfs-cache-max-age 72h"
          "--vfs-read-ahead 128M"
          "--dir-cache-time 5m"
          "--poll-interval 1m"
          "--log-level INFO"
        ];
        ExecStop        = "${pkgs.fuse}/bin/fusermount -u ${homeDirectory}/ProtonDrive";
        Restart         = "on-failure";
        RestartSec      = 10;
        TimeoutStopSec  = 20;
      };

      Install = {
        WantedBy = [ "default.target" ];
      };
    };
  };
}
