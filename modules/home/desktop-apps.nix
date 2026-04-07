# modules/home/desktop-apps.nix
# Linux-only: GUI desktop applications managed by Nix.
# On macOS these are managed by Homebrew casks (dotfiles-private/darwin/homebrew.nix).
#
# Unfree packages (vscode, obsidian, discord, spotify, zoom-us, slack, bitwig-studio,
# jetbrains.*) are permitted by nixpkgs.config.allowUnfree = true in modules/nixos/base.nix.
{ ... }:

{
  flake.modules.homeManager.desktop-apps = { pkgs, lib, ... }:
    let
      # VA-API is stripped from the wrapper here. The nixpkgs brave wrapper injects
      # --enable-features=VaapiVideoDecoder,VaapiVideoEncoder via gappsWrapperArgs
      # --add-flags in preFixup, and also prepends mesa-24.x/lib to LD_LIBRARY_PATH.
      # Mesa's libgbm then loads instead of NVIDIA's; Mesa's GBM rejects the NV12
      # format that Chromium's GPU process requests for VA-API decode → SIGTRAP.
      # Appending --disable-features via commandLineArgs does NOT override this:
      # Brave's flag merger honours first-occurrence priority, so the earlier
      # --enable-features wins. Fix: strip VaapiVideoDecoder,VaapiVideoEncoder from
      # preFixup so they never reach the exec line.
      # commandLineArgs is threaded in first via .override (which expands the empty
      # --add-flags '' placeholder in preFixup), then .overrideAttrs strips VA-API.
      brave-patched = (pkgs.brave.override {
        commandLineArgs = "--password-store=basic";
      }).overrideAttrs (old: {
        preFixup = builtins.replaceStrings
          [ "VaapiVideoDecoder,VaapiVideoEncoder" ]
          [ "" ]
          old.preFixup;
      });
    in
    {
    home.packages = with pkgs; [
      # ── Browsers ──────────────────────────────────────────────────────────────
      brave-patched  # see let binding above — VA-API stripped, --password-store=basic injected

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

    # ── Web apps (PWA-style via Brave --app) ──────────────────────────────────────
    # Sites without native Linux apps; opened in Brave app mode (no browser chrome).
    # Icons use Papirus-Dark names (resolved by the icon theme at runtime — no files fetched).
    xdg.desktopEntries = {
      raindrop = {
        name       = "Raindrop.io";
        icon       = "com.github.bartzaalberg.bookmark-manager";
        exec       = "brave --app=https://app.raindrop.io";
        comment    = "Bookmark manager";
        categories = [ "Utility" ];
      };
      workflowy = {
        name       = "WorkFlowy";
        icon       = "workflowy";
        exec       = "brave --app=https://workflowy.com";
        comment    = "Outliner and note-taking";
        categories = [ "Utility" "Office" ];
      };
      hardcover = {
        name       = "Hardcover";
        icon       = "calibre";
        exec       = "brave --app=https://hardcover.app";
        comment    = "Book tracker";
        categories = [ "Utility" ];
      };
      protonmail = {
        name       = "Proton Mail";
        icon       = "proton-mail";
        exec       = "brave --app=https://mail.proton.me";
        comment    = "Encrypted email";
        categories = [ "Network" "Email" ];
      };
      protoncalendar = {
        name       = "Proton Calendar";
        icon       = "gnome-calendar";
        exec       = "brave --app=https://calendar.proton.me";
        comment    = "Encrypted calendar";
        categories = [ "Utility" "Calendar" ];
      };
      protondrive = {
        name       = "Proton Drive";
        # No matching icon in Papirus-Dark; falls back to generic app icon.
        # google-drive is misleading so omitted.
        exec       = "brave --app=https://drive.proton.me";
        comment    = "Encrypted cloud storage";
        categories = [ "Utility" "FileManager" ];
      };
    };
  };
}
