# modules/nixos/virt.nix
# Virtualisation — libvirt + virt-manager.
# virt-manager GUI is installed via home/desktop-apps.nix.
# This module enables the system-level daemon and adds the user to the libvirtd group.
{ ... }:

{
  flake.modules.nixos.virt = { ... }: {
    # libvirtd — daemon for managing VMs (KVM/QEMU)
    virtualisation.libvirtd = {
      enable       = true;
      qemu.ovmf.enable = true;   # UEFI firmware for VMs
    };

    # SPICE USB redirection — allows passing USB devices to VMs
    virtualisation.spiceUSBRedirection.enable = true;

    # Add user to libvirtd group (required to manage VMs without root)
    users.users.jasper.extraGroups = [ "libvirtd" ];
  };
}
