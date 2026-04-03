# modules/homelab/k8s-lab.nix
# k3s Kubernetes lab — runs inside incus VMs for isolation.
# Populated in Phase 4.
{ ... }:

{
  # k3s cluster runs inside incus VMs — not on the host directly.
  # This module will manage supporting tooling (kubectl config, etc.)
  # once the lab VMs are provisioned.
}
