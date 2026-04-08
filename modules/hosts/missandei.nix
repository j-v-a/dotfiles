# modules/hosts/missandei.nix
# Personal NixOS workstation — Ryzen 9 5900X, Gigabyte Aorus B550, GTX 1060 (Pascal).
# Declares the feature list; modules/lib/nixos-host.nix assembles the system.
#
# Each feature activates both the NixOS system config AND the home-manager user config
# from a single entry. Add/remove a name to enable/disable the whole feature.
{ config, ... }:

{
  flake.nixosConfigurations.missandei =
    config.flake.lib.loadNixosAndHmModuleForUser config {
      hostname = "missandei";
      system   = "x86_64-linux";
      username = "jasper";
      features = [
        "base"              # NixOS: bootloader, locale, nix settings, SSH, docker, syncthing
        "users"             # NixOS: primary user account + group memberships
        "nvidia"            # NixOS: GTX 1060 driver config
        "hyprland"          # NixOS: Hyprland WM + pipewire  /  HM: waybar, rofi, kitty, GTK
        "gnome"             # NixOS: GNOME desktop + GDM (session picker for both WMs)
        "dev"               # NixOS: kubectl, helm, terraform, flux, kubent, etc.
        "gaming"            # NixOS: steam, lutris, gamemode
        "virt"              # NixOS: libvirtd + SPICE for virt-manager
        "wireshark"         # NixOS: setcap packet capture permissions
        "system-utils"      # NixOS: ananicy-cpp daemon + kdeconnect firewall ports
        "shell"             # HM: fish, starship, zoxide, fzf, direnv
        "atuin"             # HM: shell history (local-only, replaces fzf-fish Ctrl+R)
        "tmux"              # HM: terminal multiplexer (prefix C-a, vi keys)
        "cli-tools"         # HM: fd, rg, bat, eza, lsd, gh, lazygit, imagemagick, etc.
        "git"               # HM: git config, delta, gh credential helper
        "editors"           # HM: neovim, zed
        "linux-toolchains"  # HM: nodejs, python, jdk, rust, go, gnused, age, fonts
        "desktop-apps"      # HM: GUI apps — browsers, IDEs, communication, media, utils
        "firefox"           # HM: Firefox + declarative extensions (NUR)
        "vscode"            # HM: VSCode + declarative extensions + settings
        "catppuccin"        # HM: Catppuccin Mocha theme for waybar/dunst/rofi/hyprland/kitty/cli
        "ai-tools"          # HM: OpenCode AppImage (Linux); Mac uses Homebrew cask
      ];
      extraNixosModules = [
        # Hardware config is not a feature (never reused); import directly.
        ../_hardware/missandei.nix
        # nixos-hardware preset for the Gigabyte B550 board.
        ({ inputs, ... }: { imports = [ inputs.nixos-hardware.nixosModules.gigabyte-b550 ]; })
        # Host-specific SSH authorised keys (personal workstation identity).
        ({ username, ... }: {
          users.users.${username}.openssh.authorizedKeys.keys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE3qjIsujENfi9C3vnIU29x82lRZ3n3y2rjIkwLDRN64"
          ];
        })
      ];
    };
}
