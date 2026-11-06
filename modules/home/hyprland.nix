# modules/home/hyprland.nix
# Hyprland user-level configuration — personal workstation only.
# Compositor look + core binds, wallpaper list, kitty, GTK/Qt/cursor/fonts.
# System-level enablement (UWSM, pipewire, XDG portals) is in modules/nixos/hyprland.nix.
# Shell (bar, notifications, lock, idle, wallpaper rotation): home/noctalia.nix.
# Launcher, window switcher, keybind cheatsheet: home/walker.nix.
_:

{
  flake.modules.homeManager.hyprland =
    {
      pkgs,
      lib,
      config,
      wallpapers,
      ...
    }:
    let
      # Wallpapers to skip, relative to the wallpapers repo (e.g. "unthemed/foo.png").
      wallpaperExclude = [
      ];
      wallpaperDir = pkgs.runCommand "wallpapers" { } ''
        cd ${wallpapers}
        find . -type f \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' \) \
          | sed 's|^\./||' | sort > $TMPDIR/all
        printf '%s\n' ${lib.escapeShellArgs wallpaperExclude} | sort > $TMPDIR/skip
        comm -23 $TMPDIR/all $TMPDIR/skip | while IFS= read -r f; do
          mkdir -p "$out/$(dirname "$f")"
          ln -s "${wallpapers}/$f" "$out/$f"
        done
      '';
    in
    {
      # ── Hyprland user config ───────────────────────────────────────────────────────
      wayland.windowManager.hyprland = {
        enable = true;

        # 26.05: configType default changed hyprlang -> lua. Our config below is
        # written in hyprlang syntax, so pin the legacy type.
        configType = "hyprlang";

        # Session is managed by UWSM (nixos/hyprland.nix: withUWSM), which provides
        # graphical-session.target and exports the environment to systemd/D-Bus.
        # HM's own hyprland-session.target must be off under UWSM (double management).
        systemd.enable = false;

        settings = {
          # Monitor — auto-detect; override once you know your display layout.
          monitor = ",preferred,auto,1";

          # Environment variables for Nvidia Wayland.
          # LIBVA_* live in nixos/nvidia.nix (sessionVariables); XDG_SESSION_TYPE is set by
          # the session; Firefox and Clutter default to Wayland, so no MOZ_/CLUTTER_ vars.
          env = [
            "GBM_BACKEND,nvidia-drm"
            "__GLX_VENDOR_LIBRARY_NAME,nvidia"
            # cursor.no_hardware_cursors = true (below) is the correct Hyprland ≥0.41 fix
            # for invisible cursors on Nvidia+Wayland. WLR_NO_HARDWARE_CURSORS was the
            # wlroots-era workaround and is now ignored.

            # Wayland-native flags for common toolkits
            "NIXOS_OZONE_WL,1" # Electron (VSCode, Obsidian, Discord, Slack, etc.)
            "QT_QPA_PLATFORM,wayland" # Qt apps
            "QT_WAYLAND_DISABLE_WINDOWDECORATION,1"
            # _JAVA_AWT_WM_NONREPARENTING fixes window decorations;
            # JAVA_TOOL_OPTIONS enables the Wayland toolkit for JetBrains IDEs
            "_JAVA_AWT_WM_NONREPARENTING,1"
            "JAVA_TOOL_OPTIONS,-Dawt.toolkit.name=WLToolkit"
            "SDL_VIDEODRIVER,wayland,x11" # SDL2 apps; x11 fallback for games
          ];

          input = {
            kb_layout = "us";
            follow_mouse = 1;
            sensitivity = 0;
          };

          # ── Look (adapted from n3rsti's dotfiles + Noctalia's Hyprland guide) ───────
          general = {
            gaps_in = 5;
            gaps_out = 10;
            border_size = 1;
            # col.active_border / col.inactive_border come from Noctalia's hyprland template
            # (`source = …/hypr/noctalia.conf`, home/noctalia.nix) so they follow the palette.
            layout = "dwindle";
          };

          cursor = {
            # Fixes invisible cursor on Nvidia+Wayland (replaces the old wlroots-era
            # WLR_NO_HARDWARE_CURSORS env var, which Hyprland ≥0.41 no longer reads).
            no_hardware_cursors = true;
          };

          decoration = {
            rounding = 15;
            rounding_power = 2;
            active_opacity = 0.95;
            inactive_opacity = 0.9;
            shadow = {
              enabled = true;
              range = 4;
              render_power = 3;
              color = "rgba(1a1a1aee)";
            };
            blur = {
              enabled = true;
              size = 3;
              passes = 2;
              vibrancy = 0.1696;
            };
          };

          animations.enabled = true;
          bezier = [
            "easeOutQuint, 0.23, 1, 0.32, 1"
            "easeInOutCubic, 0.65, 0.05, 0.36, 1"
            "linear, 0, 0, 1, 1"
            "almostLinear, 0.5, 0.5, 0.75, 1"
            "quick, 0.15, 0, 0.1, 1"
          ];
          animation = [
            "global, 1, 10, default"
            "border, 1, 5.39, easeOutQuint"
            "windows, 1, 4.79, easeOutQuint"
            "windowsIn, 1, 4.1, easeOutQuint, popin 87%"
            "windowsOut, 1, 1.49, linear, popin 87%"
            "fadeIn, 1, 1.73, almostLinear"
            "fadeOut, 1, 1.46, almostLinear"
            "fade, 1, 3.03, quick"
            "layers, 1, 3.81, easeOutQuint"
            "layersIn, 1, 4, easeOutQuint, fade"
            "layersOut, 1, 1.5, linear, fade"
            "fadeLayersIn, 1, 1.79, almostLinear"
            "fadeLayersOut, 1, 1.39, almostLinear"
            "workspaces, 1, 2, easeOutQuint"
          ];

          dwindle = {
            # `pseudotile` config bool was removed in Hyprland 0.55 — pseudotiling is
            # now runtime-only (the `pseudo` window dispatcher, bound to $mod+P below).
            preserve_split = true;
          };

          # ── Keybinds ────────────────────────────────────────────────────────────────
          # Shell/launcher binds live with their feature (home/noctalia.nix, home/walker.nix);
          # all lists merge, and Super+Shift+/ shows the merged result (walker.nix).
          "$mod" = "SUPER";

          bind = [
            # Apps + session
            "$mod, Return, exec, kitty"
            "$mod, E, exec, nautilus"
            "$mod, Q, killactive"
            "$mod, M, exec, uwsm stop"

            # Window layout
            "$mod, V, togglefloating"
            "$mod, P, pseudo"
            "$mod, J, layoutmsg, togglesplit"

            # Focus
            "$mod, left,  movefocus, l"
            "$mod, right, movefocus, r"
            "$mod, up,    movefocus, u"
            "$mod, down,  movefocus, d"

            # Workspaces 1–9
            "$mod, 1, workspace, 1"
            "$mod, 2, workspace, 2"
            "$mod, 3, workspace, 3"
            "$mod, 4, workspace, 4"
            "$mod, 5, workspace, 5"
            "$mod, 6, workspace, 6"
            "$mod, 7, workspace, 7"
            "$mod, 8, workspace, 8"
            "$mod, 9, workspace, 9"
            "$mod, 0, workspace, 10"

            # Move to workspace
            "$mod SHIFT, 1, movetoworkspace, 1"
            "$mod SHIFT, 2, movetoworkspace, 2"
            "$mod SHIFT, 3, movetoworkspace, 3"
            "$mod SHIFT, 4, movetoworkspace, 4"
            "$mod SHIFT, 5, movetoworkspace, 5"
            "$mod SHIFT, 6, movetoworkspace, 6"
            "$mod SHIFT, 7, movetoworkspace, 7"
            "$mod SHIFT, 8, movetoworkspace, 8"
            "$mod SHIFT, 9, movetoworkspace, 9"
            "$mod SHIFT, 0, movetoworkspace, 10"

            # Wallpaper (Noctalia): random next / show current file relative to the
            # wallpapers repo, ready to paste into wallpaperExclude above.
            "$mod, W, exec, noctalia msg wallpaper-random"
            "$mod SHIFT, W, exec, wallpaper-current"

            # Screenshots
            ", Print, exec, grimblast copy area"
          ];

          bindm = [
            # Mouse window drag/resize
            "$mod, mouse:272, movewindow"
            "$mod, mouse:273, resizewindow"
          ];
        };
      };

      # ── Wallpapers (rotated by Noctalia) ──────────────────────────────────────────
      # Base wallpapers come from the pinned teowelton/Wallpapers flake input; disliked
      # images go in wallpaperExclude (Super+Shift+W shows the path to add). The rest are
      # symlinked into wallpaperDir — Noctalia's scan follows file symlinks (is_regular_file)
      # and recurses into the collection's subfolders.
      programs.noctalia.settings.wallpaper = {
        enabled = true;
        directory = "${wallpaperDir}";
        fill_mode = "crop";
        transition = [ "fade" ];
        automation = {
          enabled = true;
          interval_seconds = 1800;
          order = "random";
          recursive = true;
        };
      };

      # ── Kitty (terminal) ──────────────────────────────────────────────────────────
      programs.kitty = {
        enable = true;
        font = {
          name = "JetBrainsMono Nerd Font Mono";
          size = 12;
        };
        settings = {
          cursor_shape = "beam";
          scrollback_lines = 10000;
          enable_audio_bell = false;
          window_padding_width = 8;
        };
      };

      # ── Desktop packages ──────────────────────────────────────────────────────────
      home.packages = with pkgs; [
        libnotify # notify-send CLI (Noctalia is the notification daemon)
        grimblast # screenshot (wlr-screencopy + slurp)
        wl-clipboard # wl-copy / wl-paste
        pavucontrol # PulseAudio/PipeWire GUI volume control
        nautilus # file manager (GTK)
        blueman # GTK bluetooth manager (replaces blueberry, removed 26.05)
        # Qt colour plugins: Noctalia's qt template writes qt{5,6}ct/colors/noctalia.conf.
        libsForQt5.qt5ct
        qt6Packages.qt6ct
        # Super+Shift+W: notify the current wallpaper relative to the wallpapers repo.
        # wallpaperDir and the input are both /nix/store/<hash>-<name>/<rel>, so stripping
        # the store prefix yields the path wallpaperExclude expects either way.
        (writeShellScriptBin "wallpaper-current" ''
          mon=$(hyprctl activeworkspace -j | ${lib.getExe jq} -r .monitor)
          path=$(noctalia msg wallpaper-get "$mon" | sed -E 's|^/nix/store/[^/]+/||')
          noctalia msg notification-show Wallpaper "$path"
        '')
      ];

      # ── GTK (Hyprland look; colours from Noctalia's gtk3/gtk4 templates) ──────────
      # Noctalia's gtk template writes gtk-{3,4}.0/noctalia.css, @imports it from gtk.css
      # and selects adw-gtk3-dark via gsettings. So HM must NOT own gtk.css: gtk4.theme is
      # null (otherwise HM writes a read-only gtk-4.0/gtk.css importing the theme).
      gtk = {
        enable = true;
        theme = {
          name = "adw-gtk3-dark";
          package = pkgs.adw-gtk3;
        };
        gtk4.theme = null;
        font = {
          name = "Adwaita Sans";
          package = pkgs.adwaita-fonts;
          size = 11;
        };
        iconTheme = {
          name = "Papirus-Dark";
          package = pkgs.papirus-icon-theme;
        };
      };

      # ── Qt ────────────────────────────────────────────────────────────────────────
      # qt.enable only adds QT_PLUGIN_PATH (so qt5ct/qt6ct plugins are found);
      # platformTheme stays null because HM would export QT_QPA_PLATFORMTHEME globally,
      # i.e. into GNOME too. The Hyprland-only variable is in uwsm/env-hyprland below.
      # qt{5,6}ct.conf are read-only HM files: they just point at Noctalia's colour file.
      qt.enable = true;
      qt.qt5ctSettings.Appearance = {
        custom_palette = true;
        color_scheme_path = "${config.xdg.configHome}/qt5ct/colors/noctalia.conf";
        icon_theme = "Papirus-Dark";
        style = "Fusion";
      };
      qt.qt6ctSettings.Appearance = {
        custom_palette = true;
        color_scheme_path = "${config.xdg.configHome}/qt6ct/colors/noctalia.conf";
        icon_theme = "Papirus-Dark";
        style = "Fusion";
      };

      # ── Cursor ────────────────────────────────────────────────────────────────────
      # Sets gtk.cursorTheme, XCURSOR_* and HYPRCURSOR_* so Hyprland, GTK/Qt and
      # Xwayland apps agree. Bibata ships only XCursor; Hyprland falls back to it.
      home.pointerCursor = {
        name = "Bibata-Modern-Classic";
        package = pkgs.bibata-cursors;
        size = 24;
        gtk.enable = true;
        x11.enable = true;
        hyprcursor.enable = true;
      };

      # UWSM sources this only for Hyprland sessions and exports it to the systemd user
      # environment, so services (Noctalia, Walker) and the apps they launch see it too.
      xdg.configFile."uwsm/env-hyprland".text = ''
        export QT_QPA_PLATFORMTHEME=qt5ct
        export XCURSOR_THEME=${config.home.pointerCursor.name}
        export XCURSOR_SIZE=${toString config.home.pointerCursor.size}
      '';

      # UWSM runs XDG autostart entries. GNOME's ibus-daemon entry excludes only GNOME/KDE,
      # so under Hyprland it pops an "IBus should be called from the desktop session" notice.
      # A same-named user entry shadows the system one; Hyprland added to NotShowIn.
      xdg.configFile."autostart/ibus-daemon.desktop".text = ''
        [Desktop Entry]
        Name=IBus
        Type=Application
        Exec=ibus-daemon --daemonize --xim
        NotShowIn=GNOME;KDE;Hyprland;
      '';
    };
}
