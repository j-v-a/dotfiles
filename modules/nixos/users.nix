# modules/nixos/users.nix
# Primary user account — single source of truth for all group memberships.
# Receives `username` from specialArgs (set in modules/lib/nixos-host.nix).
#
# Groups gathered here from all features that need them:
#   wheel, networkmanager, video, audio  — base system access
#   docker                               — container access (root-equivalent, single-user machine)
#   gamemode                             — CPU/GPU governor control for gaming (programs.gamemode)
#   libvirtd                             — VM management without root (virtualisation/virt.nix)
#   wireshark                            — non-root packet capture (programs.wireshark)
#
# SSH authorised keys live in hosts/<hostname>.nix (host-specific identity).
#
# Password: sops secret `<username>-password-hash` (yescrypt hash, `mkpasswd -m yescrypt`),
# only wired in once secrets/<hostname>.yaml exists. users.mutableUsers stays true (NixOS
# default), so hashedPasswordFile only sets the password when the account is CREATED —
# for an existing account it is inert and `passwd` keeps working. Setting
# mutableUsers = false would make it authoritative on every activation; do that only after
# verifying the secret decrypts (a broken hash/secret would lock the account out).
_:

{
  flake.modules.nixos.users =
    {
      config,
      lib,
      pkgs,
      username,
      ...
    }:
    let
      hasSecrets = builtins.pathExists ../../secrets/${config.networking.hostName}.yaml;
      secret = "${username}-password-hash";
    in
    {
      sops.secrets.${secret} = lib.mkIf hasSecrets { neededForUsers = true; };
      users.users.${username} = {
        hashedPasswordFile = lib.mkIf hasSecrets config.sops.secrets.${secret}.path;
        isNormalUser = true;
        description = username;
        shell = pkgs.fish;
        extraGroups = [
          "wheel"
          "networkmanager"
          "video"
          "audio"
          "docker"
          "gamemode"
          "libvirtd"
          "wireshark"
        ];
      };
    };
}
