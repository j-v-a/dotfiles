# modules/dev/default.nix
# Dev tooling — shared across all dev devices (system-level).
# Kubernetes, Terraform, ArgoCD, cloud CLIs.
# Language toolchains are in languages.nix (Linux only — Mac uses version managers).
{ pkgs, lib, ... }:

{
  imports = [
    ./containers.nix
  ];
}
