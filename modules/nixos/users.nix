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
{ ... }:

{
  flake.modules.nixos.users = { pkgs, username, ... }: {
    users.users.${username} = {
      isNormalUser = true;
      description  = username;
      shell        = pkgs.fish;
      extraGroups  = [
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
