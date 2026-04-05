# home/linux.nix
# Linux home-manager config — NixOS workstation, Surface, home server.
# On Linux we use full Nix-native language toolchains (no nvm/pyenv/jenv/sdkman).
{ pkgs, ... }:

{
  imports = [
    ./common.nix
    ./modules/desktop.nix   # Hyprland user config, waybar, rofi (created below)
  ];

  home.username    = "jasper";
  home.homeDirectory = "/home/jasper";

  # ── Language toolchains (Nix-native on Linux) ─────────────────────────────────
  # On Mac these are managed by nvm/pyenv/jenv/sdkman (imperative, outside Nix).
  # On NixOS we pin everything declaratively.
  home.packages = with pkgs; [
    # Node.js
    nodejs_22

    # Python
    python313
    python313Packages.pip
    uv               # fast Python package installer / venv manager

    # JVM
    jdk21
    gradle
    maven

    # Rust
    rustup           # manages toolchains; rustup itself is Nix-pinned

    # Go
    go

    # Shell utilities — Linux-only
    pciutils         # lspci (GPU debugging)
    usbutils         # lsusb
    nvtopPackages.nvidia  # GPU monitor
    age              # encryption tool for sops-nix secrets

    # Fonts (needed for Hyprland + Waybar)
    # nixos-24.11 uses monolithic nerdfonts with an override selector;
    # the split nerd-fonts.<name> packaging only landed in nixos-unstable/25.05.
    (nerdfonts.override { fonts = [ "JetBrainsMono" "FiraCode" ]; })
    font-awesome     # waybar icons
  ];

  # ── Git credential helper — Linux uses gh CLI auth directly ───────────────────
  # On Mac we go through 1Password CLI (set in dotfiles-private/hosts/work-mac/git.nix).
  # On Linux, gh CLI manages its own token (~/.config/gh/).
  # Run once after first boot: gh auth login
  programs.git.extraConfig = {
    "credential \"https://github.com/\"".helper = "!gh auth git-credential";
  };

  # ── SSH agent — use ssh-agent or gpg-agent on Linux ──────────────────────────
  # 1Password SSH agent is not available on Linux; use the system SSH agent.
  services.ssh-agent.enable = true;
}
