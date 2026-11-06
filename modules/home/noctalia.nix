# modules/home/noctalia.nix
# Noctalia desktop shell for the Hyprland session: bar, notifications, OSD, lock screen,
# idle, polkit agent, session menu, wallpaper rotation and the desktop colour palette.
# Replaces waybar, dunst, hypridle, hyprlock, wlogout, wpaperd and nwg-drawer.
#
# Config layering: programs.noctalia.settings → read-only ~/.config/noctalia/config.toml
# (base layer). The Settings UI writes ~/.local/state/noctalia/settings.toml, which loads
# last and wins — so runtime tweaks keep working; delete that file to return to Nix values.
#
# Colours: Noctalia owns the palette on Linux and renders it via built-in templates
# (kitty, GTK, Qt, Hyprland, btop). HM-managed configs are read-only, so the includes the
# templates would add are declared here instead (see "Template wiring").
{ inputs, ... }:

{
  flake.modules.nixos.noctalia = _: {
    # Upstream binary cache. Only hits when the noctalia input does not follow our nixpkgs
    # (flake.nix does follow, so expect local builds); harmless otherwise.
    nix.settings = {
      extra-substituters = [ "https://noctalia.cachix.org" ];
      extra-trusted-public-keys = [
        "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
      ];
    };
  };

  flake.modules.homeManager.noctalia =
    { config, lib, ... }:
    let
      hyprNoctalia = "${config.xdg.configHome}/hypr/noctalia.conf";
      kittyNoctalia = "${config.xdg.configHome}/kitty/themes/noctalia.conf";
    in
    {
      imports = [ inputs.noctalia.homeModules.default ];

      # ── Wallpaper rotation ──────────────────────────────────────────────────────────
      # Collection + exclude list: home/wayland-common.nix (required by this feature).
      # Noctalia's scan follows file symlinks (is_regular_file) and recurses into the
      # collection's subfolders.
      programs.noctalia.settings.wallpaper = {
        enabled = true;
        directory = "${config.desktop.wallpaperDir}";
        fill_mode = "crop";
        transition = [ "fade" ];
        automation = {
          enabled = true;
          interval_seconds = 1800;
          order = "random";
          recursive = true;
        };
      };

      programs.noctalia = {
        enable = true;
        # User unit on graphical-session.target (reached via UWSM); gated below.
        systemd.enable = true;

        settings = {
          shell = {
            font_family = "Adwaita Sans";
            corner_radius_scale = 0.6;
            settings_window_translucent = true;
            # Hyprland has no polkit agent of its own (GNOME's lives in gnome-shell).
            polkit_agent = true;
            # Apps started from Noctalia get their own transient units, so restarting the
            # noctalia service (e.g. after a rebuild) doesn't kill them.
            launch_apps_as_systemd_services = true;
            # Config is declarative; the first-run wizard would only write overrides.
            setup_wizard_enabled = false;
            telemetry_enabled = false;
            panel = {
              transparency_mode = "glass";
              session_placement = "floating";
              session_position = "center";
            };
          };

          theme = {
            mode = "dark";
            source = "builtin";
            builtin = "Catppuccin";
            # Don't write GNOME's org.gnome.desktop.interface color-scheme: dconf is shared
            # with the GNOME session, which should stay untouched.
            sync_color_scheme = false;
            templates = {
              enable_builtin_templates = true;
              builtin_ids = [
                "kitty"
                "gtk3"
                "gtk4"
                "qt"
                "hyprland"
                "btop"
              ];
            };
          };

          # Top bar with glass capsules (look after n3rsti's config). Desktop: no battery
          # or brightness widgets.
          bar.default = {
            position = "top";
            thickness = 38;
            scale = 0.9;
            margin_ends = 0;
            background_opacity = 0.45;
            contact_shadow = true;
            font_family = "Adwaita Sans";
            font_weight = 600;
            capsule = true;
            capsule_border = "outline";
            capsule_fill = "surface";
            capsule_opacity = 0.69;
            capsule_padding = 19;
            capsule_radius = 17;
            capsule_thickness = 0.95;
            start = [
              "workspaces"
              "tray"
            ];
            center = [
              "clock"
              "media"
            ];
            end = [
              "volume"
              "bluetooth"
              "network"
              "notifications"
              "session"
            ];
          };

          widget = {
            clock.format = "{:%a %d %b  %H:%M}";
            media = {
              hide_when_no_media = true;
              max_length = 180;
              title_scroll = "on_hover";
            };
            workspaces = {
              capsule_radius = 12;
              empty_color = "surface";
              occupied_color = "surface";
              font_weight = 700;
              inactive_pill_size = 1.2;
              scale = 1.25;
            };
          };

          # Same timings as the old hypridle setup: lock at 5 min, displays off at 6 min.
          # Lock-before-suspend is Noctalia's logind sleep-delay inhibitor.
          idle = {
            behavior_order = [
              "lock"
              "screen-off"
            ];
            behavior = {
              lock = {
                action = "lock";
                enabled = true;
                timeout = 300;
              };
              screen-off = {
                action = "screen_off";
                enabled = true;
                timeout = 360;
              };
            };
          };

          lockscreen = {
            lock_before_suspend = true;
            fingerprint = false;
            transition = [ "fade" ];
            transition_duration = 300;
          };

          # Privacy: no IP geolocation, no weather fetches.
          location.auto_locate = false;
          weather.enabled = false;

          desktop_widgets.enabled = false;
        };
      };

      # graphical-session.target is also reached in GNOME; Noctalia must never run there
      # (it would add a second bar, notification daemon and idle/lock handling).
      systemd.user.services.noctalia.Unit.ConditionEnvironment = [
        "WAYLAND_DISPLAY"
        "XDG_CURRENT_DESKTOP=Hyprland"
      ];

      wayland.windowManager.hyprland.settings = {
        # ── Template wiring ──────────────────────────────────────────────────────────
        # Noctalia's hyprland template renders hypr/noctalia.conf (border colours). Its
        # hook can't append to the read-only hyprland.conf, but it skips appending when a
        # `source = …noctalia.conf` line already exists — this one.
        source = [ hyprNoctalia ];

        bind = [
          # Shell
          "$mod, L, exec, noctalia msg session lock"
          "$mod SHIFT, E, exec, noctalia msg panel-toggle session"
          "$mod, S, exec, noctalia msg panel-toggle control-center"
          "$mod, N, exec, noctalia msg panel-toggle control-center network"
          "$mod, comma, exec, noctalia msg settings-toggle"
          # Notifications: history / clear history
          "$mod, slash, exec, noctalia msg panel-toggle control-center notifications"
          "$mod CTRL, slash, exec, noctalia msg notification-clear-history"
        ];
        # Volume keys repeat when held and work on the lock screen; media keys too.
        bindel = [
          ", XF86AudioRaiseVolume, exec, noctalia msg volume-up"
          ", XF86AudioLowerVolume, exec, noctalia msg volume-down"
        ];
        bindl = [
          ", XF86AudioMute, exec, noctalia msg volume-mute"
          ", XF86AudioPlay, exec, noctalia msg media toggle"
          ", XF86AudioNext, exec, noctalia msg media next"
          ", XF86AudioPrev, exec, noctalia msg media previous"
        ];

        # Blur behind Noctalia's translucent surfaces; Noctalia animates them itself.
        # (Hyprland ≥0.53 rule syntax: `effect value, …, match:prop regex`.)
        layerrule = [
          "blur on, blur_popups on, ignore_alpha 0.3, no_anim on, match:namespace ^noctalia-(bar-.+|notification|dock|panel|attached-panel|osd|window-switcher)$"
        ];
        windowrule = [
          "float on, size 1080 920, match:class ^(dev\\.noctalia\\.Noctalia)$"
        ];
      };

      # kitty: same trick — the template's hook leaves kitty.conf alone when this exact
      # include line is present.
      programs.kitty.extraConfig = ''
        include themes/noctalia.conf
      '';

      # Hyprland treats a missing `source` file as a config error (glob "found no match"),
      # and kitty warns on a missing include. Until Noctalia's first theme render, provide
      # empty placeholders — created only if absent, never overwriting rendered output.
      home.activation.noctaliaTemplatePlaceholders = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        for f in ${
          lib.escapeShellArgs [
            hyprNoctalia
            kittyNoctalia
          ]
        }; do
          if [ ! -e "$f" ]; then
            run mkdir -p "$(dirname "$f")"
            run touch "$f"
          fi
        done
      '';
    };
}
