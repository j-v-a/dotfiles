# modules/nixos/base.nix
# Base NixOS configuration — common to all NixOS devices.
# Covers: bootloader, locale, nix settings, SSH, Docker, Syncthing, user account.
{ ... }:

{
  flake.modules.nixos.base = { pkgs, lib, ... }: {

    # ── Bootloader ────────────────────────────────────────────────────────────────
    boot.loader.systemd-boot.enable    = true;
    boot.loader.efi.canTouchEfiVariables = true;

    # ── Networking ────────────────────────────────────────────────────────────────
    networking.networkmanager.enable = true;

    # ── Firewall ──────────────────────────────────────────────────────────────────
    # NixOS enables the firewall by default; be explicit so it survives audits.
    networking.firewall = {
      enable          = true;
      allowedTCPPorts = [ 22 ];   # SSH — add more ports in host-specific modules
    };

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
      # Declarative authorized keys — survive reinstall.
      # id_ed25519_personalgh from work-mac (jvanameijden@gmail.com)
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE3qjIsujENfi9C3vnIU29x82lRZ3n3y2rjIkwLDRN64 jvanameijden@gmail.com"
      ];
    };

    # Enable Fish system-wide so it is a valid login shell.
    programs.fish.enable = true;

    # ── Unfree packages ───────────────────────────────────────────────────────────
    # Enumerate each unfree package explicitly rather than blanket-allowing all.
    # Add to this list when a new unfree package is introduced in any feature module.
    # Uses lib.getName (strips version suffix) as recommended by nixpkgs.
    # Current unfree packages:
    #   nvidia*              — from nixos/nvidia.nix      (proprietary Nvidia drivers)
    #   steam*               — from nixos/gaming.nix      (Valve Steam client)
    #   proton-ge-bin        — from nixos/gaming.nix      (custom Proton build, binary dist)
    #   terraform            — from nixos/dev.nix          (BSL 1.1 since HashiCorp relicense)
    #   vscode               — from home/desktop-apps.nix (Microsoft license)
    #   obsidian             — from home/desktop-apps.nix (proprietary)
    #   discord              — from home/desktop-apps.nix (proprietary)
    #   spotify              — from home/desktop-apps.nix (proprietary)
    #   zoom                 — from home/desktop-apps.nix (proprietary)
    #   slack                — from home/desktop-apps.nix (proprietary)
    #   bitwig-studio        — from home/desktop-apps.nix (commercial DAW)
    #   vcv-rack             — from home/desktop-apps.nix (cc-by-nc-40 + unfreeRedistributable bundled assets)
    #   idea-ultimate        — from home/desktop-apps.nix (JetBrains commercial)
    #   pycharm-professional — from home/desktop-apps.nix (JetBrains commercial)
    #   goland               — from home/desktop-apps.nix (JetBrains commercial)
    #   webstorm             — from home/desktop-apps.nix (JetBrains commercial)
    #   datagrip             — from home/desktop-apps.nix (JetBrains commercial)
    nixpkgs.config.allowUnfreePredicate = pkg:
      builtins.elem (lib.getName pkg) [
        # Nvidia drivers
        "nvidia-x11"
        "nvidia-settings"
        "nvidia-persistenced"
        # Steam + Proton
        "steam"
        "steam-original"
        "steam-run"
        "steam-unwrapped"
        "proton-ge-bin"
        # Dev tools
        "terraform"
        # Desktop apps (home/desktop-apps.nix)
        "vscode"
        "obsidian"
        "discord"
        "spotify"
        "zoom"
        "slack"
        "bitwig-studio"
        "vcv-rack"
        # JetBrains IDEs (home/desktop-apps.nix)
        "idea-ultimate"
        "pycharm-professional"
        "goland"
        "webstorm"
        "datagrip"
      ];

    # ── SSH ───────────────────────────────────────────────────────────────────────
    services.openssh = {
      enable   = true;
      settings = {
        PasswordAuthentication = false;
        PermitRootLogin        = "no";
      };
    };

    # ── Docker ────────────────────────────────────────────────────────────────────
    # WARNING: membership of the `docker` group is root-equivalent.
    # Any process running as jasper can escape to root via `docker run --privileged`.
    # Rootless Docker would eliminate this, but requires richer config and breaks
    # some compose workflows. Accept the risk for a single-user personal workstation;
    # revisit if the machine ever serves multiple users or faces a stronger threat model.
    virtualisation.docker = {
      enable = true;
      daemon.settings.features.containerd-snapshotter = true;
    };

    # ── Syncthing ─────────────────────────────────────────────────────────────────
    # Runs as user jasper; web UI at http://localhost:8384
    # Device pairing is done manually in the web UI after first boot.
    # NOTE: Set a GUI password in the web UI on first boot — Nix cannot manage
    # the hashed password declaratively without storing secrets in the Nix store.
    services.syncthing = {
      enable    = true;
      user      = "jasper";
      dataDir   = "/home/jasper";
      configDir = "/home/jasper/.config/syncthing";
      settings.gui.address = "127.0.0.1:8384";  # loopback only — not LAN-exposed
    };

    # ── Sudo ──────────────────────────────────────────────────────────────────────
    # Allow jasper to run nixos-rebuild without a password so remote rebuilds
    # (e.g. from the work-mac via SSH) don't require an interactive TTY.
    security.sudo.extraRules = [
      {
        users   = [ "jasper" ];
        commands = [
          { command = "/run/current-system/sw/bin/nixos-rebuild"; options = [ "NOPASSWD" ]; }
        ];
      }
    ];

    # ── Nix settings ──────────────────────────────────────────────────────────────
    nix.settings = {
      experimental-features = [ "nix-command" "flakes" ];
      trusted-users         = [ "jasper" ];  # root is always trusted implicitly
      auto-optimise-store   = true;  # Linux supports this (unlike Darwin)
    };

    # Set at install time — NEVER change after first boot.
    system.stateVersion = "24.11";
  };
}
