# modules/home/hyprland.nix
# Hyprland user-level configuration — personal workstation only.
# System-level Hyprland enablement is in modules/nixos/hyprland.nix.
# This file manages: Hyprland config, waybar, rofi, dunst, desktop packages, GTK.
#
# systemd integration note: hyprland.systemd.enable = true makes Hyprland register
# itself as a systemd target (hyprland-session.target). Waybar and Dunst are then
# started as systemd user services (programs.waybar.systemd / services.dunst) which
# wait on that target. This is more reliable than exec-once and ensures the Hyprland
# IPC socket is available before Waybar tries to connect to it (needed for
# hyprland/workspaces module).
{ ... }:

{
  flake.modules.homeManager.hyprland = { pkgs, homeDirectory, wallpapers, ... }: {
    # ── Hyprland user config ───────────────────────────────────────────────────────
    wayland.windowManager.hyprland = {
      enable = true;

      # Register Hyprland as a systemd session target so that waybar, dunst, and
      # other services can declare After=hyprland-session.target and start reliably.
      systemd.enable = true;

      settings = {
        # Monitor — auto-detect; override once you know your display layout.
        monitor = ",preferred,auto,1";

        # Environment variables for Nvidia Wayland
        env = [
          "LIBVA_DRIVER_NAME,nvidia"
          "XDG_SESSION_TYPE,wayland"
          "GBM_BACKEND,nvidia-drm"
          "__GLX_VENDOR_LIBRARY_NAME,nvidia"
          "WLR_NO_HARDWARE_CURSORS,1"  # fixes invisible cursor on Nvidia+Wayland

          # Wayland-native flags for common toolkits
          # Electron (VSCode, Obsidian, Discord, Slack, etc.)
          "NIXOS_OZONE_WL,1"
          # Qt apps (KDE apps, etc.)
          "QT_QPA_PLATFORM,wayland"
          "QT_WAYLAND_DISABLE_WINDOWDECORATION,1"
          # Firefox / Thunderbird
          "MOZ_ENABLE_WAYLAND,1"
          # Java/JVM apps — _JAVA_AWT_WM_NONREPARENTING fixes window decorations;
          # JAVA_TOOL_OPTIONS enables the Wayland toolkit for JetBrains IDEs
          "_JAVA_AWT_WM_NONREPARENTING,1"
          "JAVA_TOOL_OPTIONS,-Dawt.toolkit.name=WLToolkit"
          # SDL2 apps
          "SDL_VIDEODRIVER,wayland"
          # Clutter (GNOME apps)
          "CLUTTER_BACKEND,wayland"
        ];

        # waybar and dunst are started as systemd user services (see below) —
        # do NOT also launch them here or you get double instances.
        # wpaperd is launched here since it has no systemd service integration.
        exec-once = [
          "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
          "wpaperd"
          "blueman-applet"
          "hypridle"
        ];

        input = {
          kb_layout    = "us";
          follow_mouse = 1;
          sensitivity  = 0;
        };

        general = {
          gaps_in   = 4;
          gaps_out  = 8;
          border_size = 2;
          "col.active_border"   = "rgba(88c0d0ff) rgba(81a1c1ff) 45deg";
          "col.inactive_border" = "rgba(4c566aff)";
          layout = "dwindle";
        };

        decoration = {
          rounding = 8;
          blur = {
            enabled = true;
            size    = 3;
            passes  = 1;
          };
        };

        animations.enabled = true;

        dwindle = {
          pseudotile    = true;
          preserve_split = true;
        };

        # ── Keybinds ────────────────────────────────────────────────────────────────
        "$mod" = "SUPER";

        bind = [
          "$mod, Return, exec, kitty"
          "$mod, Q, killactive"
          "$mod, M, exit"
          "$mod, L, exec, hyprlock"
          "$mod SHIFT, E, exec, wlogout"
          "$mod, E, exec, nautilus"
          "$mod, V, togglefloating"
          "$mod, R, exec, rofi -modi drun -show drun"
          "$mod, P, pseudo"
          "$mod, J, togglesplit"

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

    # ── Waybar ────────────────────────────────────────────────────────────────────
    programs.waybar = {
      enable = true;

      # Start waybar as a systemd user service after hyprland-session.target.
      # This ensures the Hyprland IPC socket exists before waybar connects to it,
      # which is required for the hyprland/workspaces module to function.
      systemd.enable = true;

      settings = [{
        layer    = "top";
        position = "top";
        modules-left   = [ "hyprland/workspaces" ];
        modules-center = [ "clock" ];
        modules-right  = [ "idle_inhibitor" "cpu" "memory" "temperature" "pulseaudio" "network" "battery" "tray" "custom/power" ];
        # Waybar clock format: {} is the time placeholder; strftime codes go inside.
        # Without {}, the format string is treated as a literal template.
        clock   = { format = " {:%a %d %b  %H:%M}"; tooltip = false; };
        cpu     = { format = " {usage}%"; interval = 5; };
        memory  = { format = " {percentage}%"; interval = 5; };
        network = {
          format-wifi         = " {essid}";
          format-ethernet     = " {ifname}";
          format-disconnected = "⚠ Disconnected";
        };
        pulseaudio = {
          format       = "{icon} {volume}%";
          format-muted = " muted";
          format-icons = { default = [ "" "" "" ]; };
          on-click     = "pavucontrol";
        };
        idle_inhibitor = {
          format = "{icon}";
          format-icons = {
            activated   = "󰛨";
            deactivated = "󰒲";
          };
          tooltip = true;
          tooltip-format-activated   = "Idle inhibitor ON — screen won't lock";
          tooltip-format-deactivated = "Idle inhibitor OFF";
        };
        "custom/power" = {
          format   = "󰀑";
          tooltip  = false;
          on-click = "wlogout";
        };
      }];

      # Minimal CSS — sets the font to a Nerd Font so all icons render correctly.
      # Without this, Waybar falls back to the system sans-serif font which has no
      # Nerd Font glyphs, causing all icons to be invisible (not even boxes).
      # catppuccin/nix will replace this style block entirely when theming is applied.
      style = ''
        * {
          font-family: "JetBrainsMono Nerd Font Mono", "JetBrainsMono Nerd Font", "Font Awesome 6 Free", monospace;
          font-size: 13px;
        }

        window#waybar {
          background-color: rgba(30, 30, 46, 0.9);
          color: #cdd6f4;
          border-bottom: 2px solid rgba(137, 180, 250, 0.5);
        }

        .modules-left, .modules-center, .modules-right {
          padding: 0 8px;
        }

        #workspaces button {
          padding: 0 6px;
          color: #6c7086;
        }

        #workspaces button.active {
          color: #cdd6f4;
          border-bottom: 2px solid #89b4fa;
        }

        #clock, #cpu, #memory, #temperature, #pulseaudio, #network, #battery, #tray, #idle-inhibitor, #custom-power {
          padding: 0 8px;
          color: #cdd6f4;
        }

        #idle-inhibitor.activated {
          color: #a6e3a1;
        }

        #custom-power {
          color: #f38ba8;
          padding: 0 12px;
          font-size: 16px;
        }
      '';
    };

    # ── Dunst (notification daemon) ───────────────────────────────────────────────
    # Use the home-manager service rather than launching dunst via exec-once.
    # The service registers on org.freedesktop.Notifications via D-Bus, which is
    # required for applications to deliver notifications. A raw exec-once binary
    # may not register correctly in all session configurations.
    services.dunst = {
      enable = true;
      settings = {
        global = {
          font            = "JetBrainsMono Nerd Font Mono 11";
          corner_radius   = 8;
          frame_width     = 2;
          frame_color     = "#89b4fa";
          background      = "#1e1e2e";
          foreground      = "#cdd6f4";
          timeout         = 5;
        };
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
        cursor_shape       = "beam";
        scrollback_lines   = 10000;
        enable_audio_bell  = false;
        window_padding_width = 8;
      };
    };

    # ── Rofi (launcher) ───────────────────────────────────────────────────────────
    # theme is set by catppuccin.nix when catppuccin is in the feature list.
    programs.rofi = {
      enable  = true;
      package = pkgs.rofi-wayland;
    };

    # ── Desktop packages ──────────────────────────────────────────────────────────
    home.packages = with pkgs; [
      libnotify       # notify-send CLI (dunst itself is managed by services.dunst above)
      grimblast       # screenshot (wlr-screencopy + slurp)
      wl-clipboard    # wl-copy / wl-paste
      pavucontrol     # PulseAudio/PipeWire GUI volume control
      nautilus        # file manager (GTK)
      gnome-themes-extra       # themes for GTK apps running under Hyprland
      papirus-icon-theme       # icon theme (replaces Adwaita)
      catppuccin-cursors.mochaDark  # cursor theme matching Catppuccin Mocha
      wpaperd         # wallpaper daemon (Wayland, wlr-layer-shell)
      blueberry       # GTK bluetooth manager (backend: blueman service in nixos/base.nix)
      wlogout         # Wayland logout/power menu screen
    ];

    # ── wpaperd (wallpaper daemon) ────────────────────────────────────────────────
    # Base wallpapers come from the pinned teowelton/Wallpapers flake input (Nix store,
    # read-only). Personal wallpapers go in ~/Pictures/Wallpapers (not managed by Nix).
    # wpaperd uses [any] to match all outputs; path can only be one directory, so we
    # point at the pinned store path. Drop personal wallpapers in the same dir by
    # symlinking: ln -s ~/Pictures/Wallpapers/* <store-path>  — or just add a second
    # wpaperd output section when you know your monitor name (hyprctl monitors).
    # wpaperctl next/previous to cycle manually.
    xdg.configFile."wpaperd/config.toml".text = ''
      [any]
      path = "${wallpapers}"
      duration = "30m"
      sorting = "random"

      [any.transition.fade]
    '';

    # ── Hypridle (idle daemon) ────────────────────────────────────────────────────
    services.hypridle = {
      enable = true;
      settings = {
        general = {
          lock_cmd        = "pidof hyprlock || hyprlock";  # don't spawn multiple hyprlock
          before_sleep_cmd = "loginctl lock-session";
          after_sleep_cmd  = "hyprctl dispatch dpms on";
        };
        listener = [
          {
            timeout  = 300;  # 5 min: lock screen
            on-timeout = "loginctl lock-session";
          }
          {
            timeout  = 360;  # 6 min: turn off displays
            on-timeout = "hyprctl dispatch dpms off";
            on-resume  = "hyprctl dispatch dpms on";
          }
        ];
      };
    };

    # ── Hyprlock (screen locker) ──────────────────────────────────────────────────
    programs.hyprlock = {
      enable = true;
      settings = {
        general = {
          disable_loading_bar = true;
          hide_cursor         = true;
        };
        background = [{
          monitor = "";
          path    = "screenshot";
          blur_passes = 3;
          blur_size   = 8;
        }];
        input-field = [{
          monitor  = "";
          size     = "300, 50";
          position = "0, -80";
          halign   = "center";
          valign   = "center";
          fade_on_empty = false;
          placeholder_text = "";
          check_color  = "rgb(cba6f7)";
          fail_color   = "rgb(f38ba8)";
          font_color   = "rgb(cdd6f4)";
          inner_color  = "rgb(313244)";
          outer_color  = "rgb(6c7086)";
          outline_thickness = 2;
          shadow_passes = 2;
        }];
        label = [{
          monitor  = "";
          text     = "$TIME";
          position = "0, 160";
          halign   = "center";
          valign   = "center";
          font_size   = 64;
          font_family = "JetBrainsMono Nerd Font Mono";
          color = "rgb(cdd6f4)";
          shadow_passes = 2;
        }];
      };
    };

    # ── GTK theme (for GTK apps running under Hyprland) ──────────────────────────
    # gtk.theme is set by catppuccin.nix when catppuccin is in the feature list.
    gtk = {
      enable = true;
      iconTheme = {
        name    = "Papirus-Dark";
        package = pkgs.papirus-icon-theme;
      };
      cursorTheme = {
        name    = "catppuccin-mocha-dark-cursors";
        package = pkgs.catppuccin-cursors.mochaDark;
        size    = 24;
      };
    };

    # Propagate cursor theme to Wayland/X11 env vars so all apps pick it up.
    home.pointerCursor = {
      name    = "catppuccin-mocha-dark-cursors";
      package = pkgs.catppuccin-cursors.mochaDark;
      size    = 24;
      gtk.enable  = true;
      x11.enable  = true;
    };
  };
}
