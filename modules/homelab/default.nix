# modules/homelab/default.nix
# Home server — entry point.
{ ... }:

{
  imports = [
    ./incus.nix
    ./network.nix
    ./services.nix
    ./k8s-lab.nix
  ];
}
