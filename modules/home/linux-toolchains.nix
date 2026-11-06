# modules/home/linux-toolchains.nix
# Linux-only home-manager config: language toolchains, Linux CLI utilities, fonts.
# On macOS these are managed by nvm/pyenv/jenv/sdkman (imperative, outside Nix).
# On NixOS we pin everything declaratively.
_:

{
  flake.modules.homeManager.linux-toolchains =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        # Node.js
        nodejs_22

        # Python
        python313
        python313Packages.pip
        uv # fast Python package installer / venv manager

        # JVM
        jdk21
        gradle
        maven

        # Rust
        rustup # manages toolchains; rustup itself is Nix-pinned

        # Go
        go

        # .NET
        dotnet-sdk_10 # .NET 10 SDK (includes runtime and CLI)

        # Shell utilities — Linux-only
        # Note: GPU monitoring via nvidia-smi (provided by hardware.nvidia — no extra package needed).
        # nvtop was considered but removed: all Nvidia nvtop variants pull in cuda-merged
        # as a build-time dependency, which is unfree and not worth adding to the allowlist.
        gnused # GNU sed (macOS uses BSD sed; ensures consistent sed behaviour)
        pciutils # lspci (GPU debugging)
        usbutils # lsusb
        age # encryption tool for sops-nix secrets

        # Fonts (needed for Hyprland/Noctalia + GNOME apps). UI font Adwaita Sans: gtk.font (wayland-common.nix).
        # 26.05: nerdfonts.override was removed; use the split nerd-fonts.<name> packages.
        nerd-fonts.jetbrains-mono # primary coding font (terminals, editors)
        nerd-fonts.fira-code # ligature coding font (on Mac via Homebrew cask)
        nerd-fonts.hack # widely-used terminal/editor fallback
        nerd-fonts.caskaydia-cove # Cascadia Code (VSCode default); ligature support
        nerd-fonts.mononoki # clean monospace for terminals
        nerd-fonts.blex-mono # IBM Plex Mono with Nerd Font patches
        nerd-fonts.iosevka # narrow coding font, popular in dev tooling
        nerd-fonts.symbols-only # symbol-only fallback — ensures icons work in any terminal font
        noto-fonts # broad Unicode coverage: Latin, Greek, Cyrillic
        noto-fonts-cjk-sans # CJK (Chinese/Japanese/Korean) glyphs
        noto-fonts-color-emoji # colour emoji (needed by browsers, GNOME, KDE apps; renamed 26.05)
      ];

      # Git credential helper — Linux uses gh CLI auth directly.
      # On macOS we go through 1Password CLI (set in dotfiles-private).
      # On Linux, gh CLI manages its own token (~/.config/gh/).
      # Run once after first boot: gh auth login
      programs.git.settings = {
        "credential \"https://github.com/\"".helper = "!gh auth git-credential";
      };

      # SSH agent — use ssh-agent on Linux (1Password SSH agent not available on Linux).
      services.ssh-agent.enable = true;
    };
}
