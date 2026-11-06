# modules/nixos/base.nix
# Base NixOS configuration — common to all NixOS hosts.
# Covers: bootloader, locale, nix settings, SSH, sops-nix defaults, firewall, nh.
# Docker, Syncthing, Bluetooth and Firefox Developer Edition are separate features
# (docker.nix, syncthing.nix, bluetooth.nix, firefox-devedition.nix).
# User account is declared in nixos/users.nix (add "users" to feature list).
_:

{
  flake.modules.nixos.base =
    {
      config,
      lib,
      username,
      ...
    }:
    let
      # Per-host sops file. Until it is committed, nothing references sops (inert).
      sopsFile = ../../secrets/${config.networking.hostName}.yaml;
    in
    {

      # ── Bootloader ────────────────────────────────────────────────────────────────
      boot.loader.systemd-boot.enable = true;
      # Caps boot-menu entries only (keeps the ESP from filling up); older generations
      # stay in the store until `nh clean` removes them (see Nix housekeeping below).
      boot.loader.systemd-boot.configurationLimit = lib.mkDefault 15;
      boot.loader.efi.canTouchEfiVariables = true;

      # Compressed RAM swap — cheap insurance against OOM during large builds.
      zramSwap.enable = lib.mkDefault true;

      # ── Networking ────────────────────────────────────────────────────────────────
      networking.networkmanager.enable = lib.mkDefault true;

      # ── Firewall ──────────────────────────────────────────────────────────────────
      networking.firewall = {
        enable = true;
        allowedTCPPorts = [ 22 ];
      };

      # ── Locale / time ─────────────────────────────────────────────────────────────
      time.timeZone = lib.mkDefault "Europe/Amsterdam";
      i18n.defaultLocale = lib.mkDefault "en_US.UTF-8";
      i18n.supportedLocales = [
        "en_US.UTF-8/UTF-8"
        "nl_NL.UTF-8/UTF-8"
        "C.UTF-8/UTF-8"
      ];
      i18n.extraLocaleSettings = {
        LC_TIME = "nl_NL.UTF-8";
        LC_MONETARY = "nl_NL.UTF-8";
      };
      console.keyMap = lib.mkDefault "us";

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

      # ── Insecure packages ─────────────────────────────────────────────────────────
      # ventoy bundles prebuilt blobs and is flagged insecure by nixpkgs (26.05).
      # We use ventoy-full (desktop-apps.nix) to make bootable USBs; permit it
      # explicitly. Review periodically — remove if no longer needed.
      nixpkgs.config.permittedInsecurePackages = [ "ventoy-1.1.12" ];

      # ── SSH ───────────────────────────────────────────────────────────────────────
      services.openssh = {
        enable = true;
        settings = {
          PasswordAuthentication = false;
          KbdInteractiveAuthentication = false;
          PermitRootLogin = "no";
          AllowUsers = [ username ];
        };
      };

      # ── Secrets (sops-nix, decision D2) ────────────────────────────────────────────
      # Decrypted at activation with the host's SSH key (age recipient via ssh-to-age, see
      # .sops.yaml). Features declare their own secrets behind the same pathExists guard.
      sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
      sops.defaultSopsFile = lib.mkIf (builtins.pathExists sopsFile) sopsFile;

      # ── Nix settings ──────────────────────────────────────────────────────────────
      nix.settings = {
        experimental-features = [
          "nix-command"
          "flakes"
        ];
        # trusted-users grants sandbox bypass and arbitrary cache substitution.
        # Accepted risk on a single-user personal workstation.
        trusted-users = [ username ];
        auto-optimise-store = true;
        # Auto-GC when free space drops below 5 GiB, up to 20 GiB free.
        min-free = 5 * 1024 * 1024 * 1024;
        max-free = 20 * 1024 * 1024 * 1024;
        download-buffer-size = 512 * 1024 * 1024;
      };

      # ── Nix housekeeping ──────────────────────────────────────────────────────────
      # nh: `nh os switch|boot|build` (nom build tree + package diff, sudo only at activation).
      # Weekly clean keeps ≥ 14 days AND ≥ 10 generations (plan decision D1).
      programs.nh = {
        enable = true;
        flake = "/home/${username}/dotfiles";
        clean = {
          enable = true;
          dates = "weekly";
          extraArgs = "--keep-since 14d --keep 10";
        };
      };

      # Run unpatched dynamic binaries (AppImages, vendor CLIs, VS Code server bits).
      programs.nix-ld.enable = true;

      # command-not-found needs channels (unused with flakes); nix-index (HM cli-tools) replaces it.
      programs.command-not-found.enable = false;
    };
}
