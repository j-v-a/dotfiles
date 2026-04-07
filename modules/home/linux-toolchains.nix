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
      # Note: GPU monitoring via nvidia-smi (provided by hardware.nvidia — no extra package needed).
      # nvtop was considered but removed: all Nvidia nvtop variants pull in cuda-merged
      # as a build-time dependency, which is unfree and not worth adding to the allowlist.
      gnused           # GNU sed (macOS uses BSD sed; ensures consistent sed behaviour)
      pciutils         # lspci (GPU debugging)
      usbutils         # lsusb
      age              # encryption tool for sops-nix secrets

      # Fonts (needed for Hyprland + Waybar + KDE/GNOME apps)
      # TODO(25.05): replace with individual nerd-fonts.* packages when upgrading to nixos-25.05.
      # The split nerd-fonts.<name> API landed in 25.05; nerdfonts.override is removed there.
      # When upgrading, replace this block with:
      #   nerd-fonts.jetbrains-mono nerd-fonts.fira-code nerd-fonts.hack
      #   nerd-fonts.cascadia-code nerd-fonts.mononoki nerd-fonts.ibm-plex-mono
      #   nerd-fonts.iosevka nerd-fonts.symbols-only
      (nerdfonts.override { fonts = [
        "JetBrainsMono"        # primary coding font (terminals, editors)
        "FiraCode"             # ligature coding font (on Mac via Homebrew cask)
        "Hack"                 # widely-used terminal/editor fallback
        "CascadiaCode"         # VSCode default; ligature support
        "Mononoki"             # clean monospace for terminals
        "IBMPlexMono"          # IBM Plex Mono with Nerd Font patches
        "Iosevka"              # narrow coding font, popular in dev tooling
        "NerdFontsSymbolsOnly" # symbol-only fallback — ensures icons work in any terminal font
      ]; })
      font-awesome          # waybar icons (solid/brands/regular sets)
      noto-fonts            # broad Unicode coverage: Latin, Greek, Cyrillic
      noto-fonts-cjk-sans   # CJK (Chinese/Japanese/Korean) glyphs
      noto-fonts-emoji      # colour emoji (needed by browsers, GNOME, KDE apps)
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
