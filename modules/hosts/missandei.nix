# modules/hosts/missandei.nix
# Personal NixOS workstation — Ryzen 9 5900X, Gigabyte Aorus B550, GTX 1060 (Pascal).
# Declares the feature list; the _lib/nixos-host.nix helper assembles the system.
#
# Features activate both NixOS system config AND home-manager user config in one step.
# Add/remove a feature name to enable/disable the whole feature (system + user).
{ config, ... }:

{
  flake.nixosConfigurations.missandei =
    config.flake.lib.loadNixosAndHmModuleForUser config {
      hostname = "missandei";
      system   = "x86_64-linux";
      username = "jasper";
      # Each feature name is looked up in BOTH flake.modules.nixos and
      # flake.modules.homeManager. A missing entry in either registry is a no-op ({}).
      # So a feature like "hyprland" activates BOTH the NixOS system config
      # (programs.hyprland, SDDM, pipewire) AND the HM user config (waybar, rofi, etc.)
      # from a single entry here.
      features = [
        "base"              # NixOS: bootloader, locale, nix settings, SSH, docker, syncthing
        "nvidia"            # NixOS: GTX 1060 driver config
        "hyprland"          # NixOS: system WM+SDDM+pipewire  /  HM: waybar, rofi, kitty, GTK
        "dev"               # NixOS: kubectl, helm, terraform, etc.
        "gaming"            # NixOS: steam, lutris, gamemode
        "shell"             # HM: fish, starship, zoxide, fzf, direnv
        "cli-tools"         # HM: fd, rg, bat, eza, gh, lazygit, etc.
        "git"               # HM: git config, delta, gh credential helper
        "editors"           # HM: neovim, zed
        "linux-toolchains"  # HM: nodejs, python, jdk, rust, go, age, fonts
      ];
      extraNixosModules = [
        # Hardware config is not a feature (never reused); import directly.
        ../_hardware/missandei.nix
        # nixos-hardware preset for the Gigabyte B550 board.
        # Injected here rather than as a feature because it's hardware-specific.
        ({ inputs, ... }: { imports = [ inputs.nixos-hardware.nixosModules.gigabyte-b550 ]; })
      ];
    };
}
