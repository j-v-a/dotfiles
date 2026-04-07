# modules/nixos/virt.nix
# Virtualisation — libvirt + virt-manager daemon.
# virt-manager GUI is installed via home/desktop-apps.nix.
# The libvirtd group is assigned in nixos/users.nix.
{ ... }:

{
  flake.modules.nixos.virt = { ... }: {
    virtualisation.libvirtd = {
      enable           = true;
      qemu.ovmf.enable = true;   # UEFI firmware for VMs
    };
    virtualisation.spiceUSBRedirection.enable = true;
  };
}
