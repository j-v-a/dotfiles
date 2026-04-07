# modules/home/desktop-apps.nix
# Linux-only: GUI desktop applications managed by Nix.
# On macOS these are managed by Homebrew casks (dotfiles-private/darwin/homebrew.nix).
#
# Unfree packages (vscode, obsidian, discord, spotify, zoom-us, slack, bitwig-studio,
# jetbrains.*) are permitted by nixpkgs.config.allowUnfree = true in modules/nixos/base.nix.
{ ... }:

{
  flake.modules.homeManager.desktop-apps = { pkgs, lib, ... }:
  {
    home.packages = with pkgs; [
      # ── Browsers ──────────────────────────────────────────────────────────────
      firefox                      # stable Firefox
      # firefox-devedition is in environment.systemPackages (nixos/base.nix) —
      # cannot coexist with firefox in home-manager home.packages (library filename collision)

      # ── Password / Identity ───────────────────────────────────────────────────
      proton-pass                  # Proton password manager + identity
      _1password-gui               # 1Password desktop client (unfree)

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

      # ── Web apps (native Electron) ────────────────────────────────────────────
      youtube-music                # YouTube Music native Electron app
    ];

    # ── Web apps (PWA-style via Firefox --new-window) ─────────────────────────────
    # Sites without native Linux apps; opened in Firefox as standalone windows.
    # Icons use Papirus-Dark names (resolved by the icon theme at runtime).
    xdg.desktopEntries = {
      raindrop = {
        name       = "Raindrop.io";
        icon       = "com.github.bartzaalberg.bookmark-manager";
        exec       = "firefox --new-window https://app.raindrop.io";
        comment    = "Bookmark manager";
        categories = [ "Utility" ];
      };
      workflowy = {
        name       = "WorkFlowy";
        icon       = "workflowy";
        exec       = "firefox --new-window https://workflowy.com";
        comment    = "Outliner and note-taking";
        categories = [ "Utility" "Office" ];
      };
      hardcover = {
        name       = "Hardcover";
        icon       = "calibre";
        exec       = "firefox --new-window https://hardcover.app";
        comment    = "Book tracker";
        categories = [ "Utility" ];
      };
      protonmail = {
        name       = "Proton Mail";
        icon       = "proton-mail";
        exec       = "firefox --new-window https://mail.proton.me";
        comment    = "Encrypted email";
        categories = [ "Network" "Email" ];
      };
      protoncalendar = {
        name       = "Proton Calendar";
        icon       = "gnome-calendar";
        exec       = "firefox --new-window https://calendar.proton.me";
        comment    = "Encrypted calendar";
        categories = [ "Utility" "Calendar" ];
      };
      protondrive = {
        name       = "Proton Drive";
        # No matching icon in Papirus-Dark; falls back to generic app icon.
        exec       = "firefox --new-window https://drive.proton.me";
        comment    = "Encrypted cloud storage";
        categories = [ "Utility" "FileManager" ];
      };
    };
  };
}
