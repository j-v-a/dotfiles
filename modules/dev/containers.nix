# modules/dev/containers.nix
# Kubernetes + cloud tooling — shared across dev devices.
{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    kubectl
    kubernetes-helm
    k9s
    kubectx
    kustomize
    argocd
    terraform
    awscli2
    azure-cli
    k3d
  ];
}
