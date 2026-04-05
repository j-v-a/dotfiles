# modules/home/linux-toolchains.nix
# Linux-only home-manager config: language toolchains, Linux CLI utilities, fonts.
# On macOS these are managed by nvm/pyenv/jenv/sdkman (imperative, outside Nix).
# On NixOS we pin everything declaratively.
{ ... }:

{
  flake.modules.homeManager.linux-toolchains = { pkgs, username, homeDirectory, ... }: {
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
      nvtopPackages.full   # GPU monitor (all vendors; no CUDA dep unlike nvtopPackages.nvidia)
      age              # encryption tool for sops-nix secrets

      # Fonts (needed for Hyprland + Waybar)
      # nixos-24.11 uses monolithic nerdfonts with an override selector;
      # the split nerd-fonts.<name> packaging only landed in nixos-unstable/25.05.
      (nerdfonts.override { fonts = [ "JetBrainsMono" "FiraCode" ]; })
      font-awesome     # waybar icons
    ];

    # Git credential helper — Linux uses gh CLI auth directly.
    # On macOS we go through 1Password CLI (set in dotfiles-private).
    # On Linux, gh CLI manages its own token (~/.config/gh/).
    # Run once after first boot: gh auth login
    programs.git.extraConfig = {
      "credential \"https://github.com/\"".helper = "!gh auth git-credential";
    };

    # SSH agent — use ssh-agent on Linux (1Password SSH agent not available on Linux).
    services.ssh-agent.enable = true;

    home.username    = username;
    home.homeDirectory = homeDirectory;
  };
}
