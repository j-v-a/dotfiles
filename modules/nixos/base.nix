# modules/nixos/base.nix
# Base NixOS configuration — common to all NixOS hosts.
# Covers: bootloader, locale, nix settings, SSH, Docker, Syncthing.
# User account is declared in nixos/users.nix (add "users" to feature list).
{ ... }:

{
  flake.modules.nixos.base = { pkgs, username, ... }: {

    # ── Bootloader ────────────────────────────────────────────────────────────────
    boot.loader.systemd-boot.enable      = true;
    boot.loader.efi.canTouchEfiVariables = true;

    # ── Networking ────────────────────────────────────────────────────────────────
    networking.networkmanager.enable = true;

    # ── Bluetooth ─────────────────────────────────────────────────────────────────
    hardware.bluetooth = {
      enable      = true;
      powerOnBoot = true;
    };
    services.blueman.enable = true;

    # ── Firewall ──────────────────────────────────────────────────────────────────
    networking.firewall = {
      enable          = true;
      allowedTCPPorts = [ 22 ];
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

    # ── Fish login shell ───────────────────────────────────────────────────────────
    # Must be enabled system-wide so Fish is a valid login shell in /etc/shells.
    # The user's shell is set to pkgs.fish in nixos/users.nix.
    programs.fish.enable = true;

    # ── Unfree packages ───────────────────────────────────────────────────────────
    # allowUnfree = true: blanket allow for this personal machine.
    # A per-module allowUnfreePredicate is not used because it is a function and
    # NixOS applies last-wins semantics to functions — distributing it across modules
    # would silently discard all but the last assignment.
    # Unfree packages by feature:
    #   nvidia.nix        — nvidia-x11, nvidia-settings, nvidia-persistenced
    #   gaming.nix        — steam, steam-original, steam-run, steam-unwrapped, proton-ge-bin
    #   dev.nix           — terraform (BSL 1.1 since HashiCorp relicense)
    #   desktop-apps.nix  — vscode, obsidian, discord, spotify, zoom, slack,
    #                        bitwig-studio, vcv-rack, 1password, JetBrains IDEs
    nixpkgs.config.allowUnfree = true;

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
    # Any process running as the user can escape to root via `docker run --privileged`.
    # Rootless Docker would eliminate this but breaks some compose workflows.
    # Accepted risk for a single-user personal workstation.
    virtualisation.docker = {
      enable = true;
      daemon.settings.features.containerd-snapshotter = true;
    };

    # ── Syncthing ─────────────────────────────────────────────────────────────────
    # Web UI at http://localhost:8384 — loopback only, not LAN-exposed.
    # Device pairing is done manually in the web UI after first boot.
    # NOTE: set a GUI password in the web UI — Nix cannot manage the hashed password
    # declaratively without storing secrets in the Nix store.
    services.syncthing = {
      enable    = true;
      user      = username;
      dataDir   = "/home/${username}";
      configDir = "/home/${username}/.config/syncthing";
      settings.gui.address = "127.0.0.1:8384";
    };

    # ── System packages ───────────────────────────────────────────────────────────
    environment.systemPackages = with pkgs; [
      # firefox-devedition cannot coexist with firefox in home-manager home.packages
      # (both install libmozavutil.so to the same profile path → collision).
      # Installing at system level avoids the merge conflict.
      firefox-devedition
    ];

    # ── Nix settings ──────────────────────────────────────────────────────────────
    nix.settings = {
      experimental-features = [ "nix-command" "flakes" ];
      # trusted-users grants sandbox bypass and arbitrary cache substitution.
      # Accepted risk on a single-user personal workstation.
      trusted-users       = [ username ];
      auto-optimise-store = true;
    };

    # Set at install time — NEVER change after first boot.
    system.stateVersion = "24.11";
  };
}
