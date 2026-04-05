# modules/nixos/dev.nix
# System-level dev tooling — Kubernetes, Terraform, ArgoCD, cloud CLIs.
# Language toolchains are in modules/home/linux-toolchains.nix (via home-manager).
{ ... }:

{
  flake.modules.nixos.dev = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      kubectl
      kubernetes-helm
      k9s
      kubectx
      kustomize
      argocd
      fluxcd          # FluxCD CLI (flux)
      kubent          # deprecated API checker
      terraform
      awscli2
      azure-cli
      k3d
    ];
  };
}
