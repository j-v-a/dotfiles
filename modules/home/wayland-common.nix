# modules/home/wayland-common.nix
# Compositor-independent Wayland desktop bits, shared by every WM (Hyprland now; niri later):
# kitty, GTK/Qt/cursor/fonts, desktop utilities and the wallpaper collection.
# Compositor-specific config (look, binds, env, UWSM env file) stays in the per-WM module
# (home/hyprland.nix). Shell (bar, notifications, wallpaper rotation): home/noctalia.nix.
_:

{
  flake.modules.homeManager.wayland-common =
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
    in
    {
      # ── Wallpapers ─────────────────────────────────────────────────────────────────
      # Base wallpapers come from the pinned teowelton/Wallpapers flake input; disliked
      # images go in wallpaperExclude (Super+Shift+W shows the path to add). The rest are
      # symlinked into wallpaperDir, which the shell (home/noctalia.nix) rotates through.
      options.desktop.wallpaperDir = lib.mkOption {
        type = lib.types.package;
        readOnly = true;
        description = "Wallpaper collection (wallpapers input minus wallpaperExclude), as symlinks.";
        default = pkgs.runCommand "wallpapers" { } ''
          cd ${wallpapers}
          find . -type f \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' \) \
            | sed 's|^\./||' | sort > $TMPDIR/all
          printf '%s\n' ${lib.escapeShellArgs wallpaperExclude} | sort > $TMPDIR/skip
          comm -23 $TMPDIR/all $TMPDIR/skip | while IFS= read -r f; do
            mkdir -p "$out/$(dirname "$f")"
            ln -s "${wallpapers}/$f" "$out/$f"
          done
        '';
      };

      config = {
        # ── Kitty (terminal) ────────────────────────────────────────────────────────
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

        # ── Desktop packages ────────────────────────────────────────────────────────
        home.packages = with pkgs; [
          libnotify # notify-send CLI (Noctalia is the notification daemon)
          wl-clipboard # wl-copy / wl-paste
          pavucontrol # PulseAudio/PipeWire GUI volume control
          nautilus # file manager (GTK)
          blueman # GTK bluetooth manager (replaces blueberry, removed 26.05)
          # Qt colour plugins: Noctalia's qt template writes qt{5,6}ct/colors/noctalia.conf.
          libsForQt5.qt5ct
          qt6Packages.qt6ct
        ];

        # ── GTK (colours from Noctalia's gtk3/gtk4 templates) ───────────────────────
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

        # ── Qt ──────────────────────────────────────────────────────────────────────
        # qt.enable only adds QT_PLUGIN_PATH (so qt5ct/qt6ct plugins are found);
        # platformTheme stays null because HM would export QT_QPA_PLATFORMTHEME globally,
        # i.e. into GNOME too. Per-WM modules set it for their session only (e.g. the
        # uwsm/env-hyprland file in home/hyprland.nix).
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

        # ── Cursor ──────────────────────────────────────────────────────────────────
        # Sets gtk.cursorTheme and XCURSOR_* so the compositor, GTK/Qt and Xwayland apps
        # agree. Compositor-specific cursor formats (hyprcursor) are enabled per WM.
        home.pointerCursor = {
          name = "Bibata-Modern-Classic";
          package = pkgs.bibata-cursors;
          size = 24;
          gtk.enable = true;
          x11.enable = true;
        };
      };
    };
}
