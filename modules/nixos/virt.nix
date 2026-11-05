# modules/nixos/virt.nix
# Virtualisation — libvirt + virt-manager daemon.
# virt-manager GUI is installed via home/desktop-apps.nix.
# The libvirtd group is assigned in nixos/users.nix.
_:

{
  flake.modules.nixos.virt = _: {
    virtualisation.libvirtd = {
      enable = true;
      # 26.05: virtualisation.libvirtd.qemu.ovmf was removed; OVMF UEFI firmware
      # images shipped with QEMU are now available by default.
    };
    virtualisation.spiceUSBRedirection.enable = true;
  };
}
