# modules/nixos/docker.nix
# Docker daemon. The `docker` group membership lives in nixos/users.nix.
_:

{
  flake.modules.nixos.docker = _: {
    # WARNING: membership of the `docker` group is root-equivalent.
    # Any process running as the user can escape to root via `docker run --privileged`.
    # Rootless Docker would eliminate this but breaks some compose workflows.
    # Accepted risk for a single-user personal workstation.
    virtualisation.docker = {
      enable = true;
      daemon.settings.features.containerd-snapshotter = true;
    };
  };
}
