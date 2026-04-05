# modules/nixos/base.nix
# Base NixOS configuration — common to all NixOS devices.
# Covers: bootloader, locale, nix settings, SSH, Docker, Syncthing, user account.
{ ... }:

{
  flake.modules.nixos.base = { pkgs, ... }: {

    # ── Bootloader ────────────────────────────────────────────────────────────────
    boot.loader.systemd-boot.enable    = true;
    boot.loader.efi.canTouchEfiVariables = true;

    # ── Networking ────────────────────────────────────────────────────────────────
    networking.networkmanager.enable = true;

    # ── Locale / time ─────────────────────────────────────────────────────────────
    time.timeZone = "Europe/Amsterdam";
    i18n.defaultLocale = "en_US.UTF-8";
    i18n.supportedLocales = [
      "en_US.UTF-8/UTF-8"
      "nl_NL.UTF-8/UTF-8"
      "C.UTF-8/UTF-8"
    ];
    i18n.extraLocaleSettings = {
      LC_TIME     = "nl_NL.UTF-8";
      LC_MONETARY = "nl_NL.UTF-8";
    };
    console.keyMap = "us";

    # ── Users ─────────────────────────────────────────────────────────────────────
    users.users.jasper = {
      isNormalUser = true;
      description  = "Jasper van Ameijden";
      extraGroups  = [ "wheel" "networkmanager" "video" "audio" "docker" "gamemode" ];
      shell        = pkgs.fish;
    };

    # Enable Fish system-wide so it is a valid login shell.
    programs.fish.enable = true;

    # ── Unfree packages ───────────────────────────────────────────────────────────
    # Set before any unfree packages (Nvidia, Steam, etc.) are imported.
    nixpkgs.config.allowUnfreePredicate = _: true;

    # ── SSH ───────────────────────────────────────────────────────────────────────
    services.openssh = {
      enable   = true;
      settings = {
        PasswordAuthentication = false;
        PermitRootLogin        = "no";
      };
    };

    # ── Docker ────────────────────────────────────────────────────────────────────
    virtualisation.docker = {
      enable = true;
      daemon.settings.features.containerd-snapshotter = true;
    };

    # ── Syncthing ─────────────────────────────────────────────────────────────────
    # Runs as user jasper; web UI at http://localhost:8384
    # Device pairing is done manually in the web UI after first boot.
    services.syncthing = {
      enable    = true;
      user      = "jasper";
      dataDir   = "/home/jasper";
      configDir = "/home/jasper/.config/syncthing";
    };

    # ── Nix settings ──────────────────────────────────────────────────────────────
    nix.settings = {
      experimental-features = [ "nix-command" "flakes" ];
      trusted-users         = [ "root" "jasper" ];
      auto-optimise-store   = true;  # Linux supports this (unlike Darwin)
    };

    # Set at install time — NEVER change after first boot.
    system.stateVersion = "24.11";
  };
}
