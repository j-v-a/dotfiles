# modules/home/desktop-apps.nix
# Linux-only: GUI desktop applications managed by Nix.
# On macOS these are managed by Homebrew casks (dotfiles-private/darwin/homebrew.nix).
#
# Unfree packages in this file that must be listed in base.nix allowUnfreePredicate:
#   vscode                      — Microsoft license
#   obsidian                    — proprietary
#   discord                     — proprietary
#   spotify                     — proprietary
#   zoom-us                     — proprietary
#   slack                       — proprietary
#   bitwig-studio               — commercial DAW license
#   jetbrains.*                 — JetBrains commercial license (each product listed separately)
{ ... }:

{
  flake.modules.homeManager.desktop-apps = { pkgs, ... }: {
    home.packages = with pkgs; [
      # ── Browsers ──────────────────────────────────────────────────────────────
      brave                        # privacy-focused Chromium browser

      # ── Communication ─────────────────────────────────────────────────────────
      discord                      # voice/text/video chat (unfree)
      zoom-us                      # video conferencing (unfree)
      slack                        # team messaging (unfree)
      signal-desktop               # encrypted messenger
      ferdium                      # multi-service messenger (wraps WhatsApp Web, Slack, etc.)
      thunderbird                  # email client

      # ── Media & Audio ─────────────────────────────────────────────────────────
      spotify                      # music streaming (unfree)
      vlc                          # video player
      mpv                          # minimal video player
      audacity                     # audio editor (runs via Xwayland)
      mousai                       # music identification (Shazam-like)
      easyeffects                  # PipeWire audio effects and EQ
      helvum                       # PipeWire patchbay / routing GUI
      vcv-rack                     # modular synth (GPL; some bundled art non-free)
      bitwig-studio                # DAW (unfree)
      hypnotix                     # IPTV player
      kooha                        # screen recorder (Wayland-native)

      # ── Productivity / Docs ────────────────────────────────────────────────────
      obsidian                     # markdown knowledge base (unfree)
      apostrophe                   # distraction-free markdown editor (GNOME)
      libreoffice                  # office suite (Wayland-native)
      onlyoffice-desktopeditors    # office suite with MS Office compatibility (Xwayland)
      kdePackages.okular           # document / PDF viewer (KDE)
      kdePackages.kate             # text editor with syntax highlighting (KDE)
      calibre                      # e-book manager and converter
      celeste                      # cloud sync GUI (rclone-based)
      komikku                      # manga reader (GNOME)
      alpaca                       # local LLM frontend (Ollama GUI)
      qalculate-gtk                # powerful calculator (GUI + qalc CLI)

      # ── File Management / System ───────────────────────────────────────────────
      kdePackages.dolphin          # file manager (KDE)
      kdePackages.kdeconnect-kde   # phone/desktop integration (KDE)
      kdePackages.spectacle        # screenshot tool (KDE)
      bleachbit                    # disk cleaner
      czkawka                      # duplicate file finder
      metadata-cleaner             # EXIF / metadata cleaner (GNOME)
      impression                   # USB flasher (GNOME)
      ventoy-full                  # bootable USB creator (all filesystem drivers)
      piper                        # gaming mouse configuration (libratbag)
      upscayl                      # AI image upscaler (AppImage repack)

      # ── Video Editing ──────────────────────────────────────────────────────────
      kdePackages.kdenlive         # non-linear video editor (KDE)
      handbrake                    # video transcoder
      losslesscut-bin              # lossless video/audio cutter (AppImage repack)

      # ── Image ─────────────────────────────────────────────────────────────────
      pinta                        # simple raster image editor (Paint.NET-like)
      switcheroo                   # image format converter (GNOME)
      identity                     # side-by-side image comparison (GNOME)

      # ── Code Editors / IDEs ───────────────────────────────────────────────────
      vscode                       # Microsoft VS Code (unfree)
      zed-editor                   # fast multiplayer code editor
      ghostty                      # GPU-accelerated terminal

      # ── JetBrains IDEs ────────────────────────────────────────────────────────
      # All JetBrains IDEs are unfree (commercial license).
      # Listed individually so the allowUnfreePredicate can be explicit.
      jetbrains.idea-ultimate      # Java / JVM (IntelliJ IDEA Ultimate)
      jetbrains.pycharm-professional  # Python
      jetbrains.goland             # Go
      jetbrains.webstorm           # JavaScript / TypeScript
      jetbrains.datagrip           # Databases / SQL

      # ── Dev Tools ─────────────────────────────────────────────────────────────
      virt-manager                 # VM manager GUI (requires nixos/virt.nix for libvirtd)
      wireshark                    # packet analyser (requires nixos/wireshark.nix)

      # ── Gaming ────────────────────────────────────────────────────────────────
      bottles                      # Wine prefix manager
      gamescope                    # Valve micro-compositor for gaming

      # ── VPN ───────────────────────────────────────────────────────────────────
      protonvpn-gui                # ProtonVPN client
    ];
  };
}
