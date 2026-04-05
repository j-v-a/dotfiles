# hosts/missandei/default.nix
# Personal NixOS workstation — Ryzen 9 5900X, Gigabyte Aorus B550, GTX 1060 (Pascal).
#
# GTX 1060 (Pascal) confirmed NOT on Nvidia legacy list → use nvidiaPackages.stable.
# If ever upgrading GPU check again: https://www.nvidia.com/en-us/drivers/unix/legacy-gpu/
{ inputs, nixos-hardware, pkgs, lib, ... }:

{
  imports = [
    nixos-hardware.nixosModules.gigabyte-b550  # B550 suspend fix + AMD microcode
    ./hardware-configuration.nix
    ../../modules/dev
    ../../modules/desktop/hyprland.nix
    ../../modules/gaming
  ];

  # ── Networking ────────────────────────────────────────────────────────────────
  networking.hostName = "missandei";
  networking.networkmanager.enable = true;

  # ── Locale / time ─────────────────────────────────────────────────────────────
  time.timeZone = "Europe/Amsterdam";
  i18n.defaultLocale = "en_GB.UTF-8";
  i18n.supportedLocales = [ "en_GB.UTF-8/UTF-8" "nl_NL.UTF-8/UTF-8" "en_US.UTF-8/UTF-8" ];
  i18n.extraLocaleSettings = {
    LC_TIME     = "nl_NL.UTF-8";  # 24h clock, European date format
    LC_MONETARY = "nl_NL.UTF-8";
  };
  console.keyMap = "us";

  # ── Bootloader ────────────────────────────────────────────────────────────────
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # ── Users ─────────────────────────────────────────────────────────────────────
  users.users.jasper = {
    isNormalUser = true;
    description  = "Jasper van Ameijden";
    extraGroups  = [ "wheel" "networkmanager" "video" "audio" "docker" "gamemode" ];
    shell        = pkgs.fish;
  };

  # Enable Fish system-wide so it is a valid login shell.
  programs.fish.enable = true;

  # sudo without password for wheel — remove this once setup is confirmed working.
  # security.sudo.wheelNeedsPassword = false;

  # ── Unfree packages ───────────────────────────────────────────────────────────
  # MUST be set before Nvidia + Steam packages are imported.
  nixpkgs.config.allowUnfreePredicate = _: true;

  # ── Nvidia (GTX 1060 — Pascal) ────────────────────────────────────────────────
  # - open = false  REQUIRED for Pascal; open kernel module only supports Turing+
  # - modesetting   REQUIRED for Hyprland / Wayland
  # - hardware.graphics replaces hardware.opengl (renamed in NixOS 24.11)
  hardware.nvidia = {
    package          = pkgs.linuxPackages.nvidiaPackages.stable;
    modesetting.enable = true;
    open             = false;
    nvidiaSettings   = true;  # installs nvidia-settings GUI
    powerManagement.enable = false;  # desktop — not a laptop
  };
  hardware.graphics.enable      = true;
  hardware.graphics.enable32Bit = true;  # needed for Steam + 32-bit games
  services.xserver.videoDrivers = [ "nvidia" ];

  # ── SSH ───────────────────────────────────────────────────────────────────────
  services.openssh = {
    enable          = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin        = "no";
    };
  };

  # ── Docker ────────────────────────────────────────────────────────────────────
  virtualisation.docker = {
    enable    = true;
    daemon.settings.features.containerd-snapshotter = true;
  };

  # ── Syncthing ─────────────────────────────────────────────────────────────────
  # Runs as user jasper; web UI at http://localhost:8384
  # Device pairing is done manually in the web UI after first boot.
  services.syncthing = {
    enable   = true;
    user     = "jasper";
    dataDir  = "/home/jasper";
    configDir = "/home/jasper/.config/syncthing";
  };

  # ── Nix settings ──────────────────────────────────────────────────────────────
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    trusted-users         = [ "root" "jasper" ];
    auto-optimise-store   = true;  # Linux supports this (unlike Darwin)
  };

  # ── home-manager ─────────────────────────────────────────────────────────────
  home-manager.users.jasper = import ../../home/linux.nix;

  # Set at install time — NEVER change after first boot.
  system.stateVersion = "24.11";
}
