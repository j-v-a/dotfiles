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
  flake.modules.homeManager.hyprland = { pkgs, ... }: {
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
        ];

        # waybar and dunst are started as systemd user services (see below) —
        # do NOT also launch them here or you get double instances.
        exec-once = [
          "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
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
        modules-right  = [ "cpu" "memory" "temperature" "pulseaudio" "network" "battery" "tray" ];
        # Waybar clock format: {} is the time placeholder; strftime codes go inside.
        # Without {}, the format string is treated as a literal template.
        # Icons use explicit Unicode escapes — literal glyphs get stripped by Nix's JSON serializer.
        # Codepoints: \uf017=clock \uf4bc=cpu \uf538=memory \uf1eb=wifi \uf796=ethernet
        #             \uf026=vol-mute \uf027=vol-low \uf028=vol-high \uf028=vol-max
        clock   = { format = "\uf017 {:%a %d %b  %H:%M}"; tooltip = false; };
        cpu     = { format = "\uf4bc {usage}%"; interval = 5; };
        memory  = { format = "\uf538 {percentage}%"; interval = 5; };
        network = {
          format-wifi         = "\uf1eb {essid}";
          format-ethernet     = "\uf796 {ifname}";
          format-disconnected = "⚠ Disconnected";
        };
        pulseaudio = {
          format       = "{icon} {volume}%";
          format-muted = "\uf026 muted";
          format-icons = { default = [ "\uf026" "\uf027" "\uf028" ]; };
          on-click     = "pavucontrol";
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

        #clock, #cpu, #memory, #temperature, #pulseaudio, #network, #battery, #tray {
          padding: 0 8px;
          color: #cdd6f4;
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

    # ── Rofi (launcher) ───────────────────────────────────────────────────────────
    # theme is set by catppuccin.nix when catppuccin is in the feature list.
    programs.rofi = {
      enable  = true;
      package = pkgs.rofi-wayland;
    };

    # ── Desktop packages ──────────────────────────────────────────────────────────
    home.packages = with pkgs; [
      kitty           # terminal
      libnotify       # notify-send CLI (dunst itself is managed by services.dunst above)
      grimblast       # screenshot (wlr-screencopy + slurp)
      wl-clipboard    # wl-copy / wl-paste
      pavucontrol     # PulseAudio/PipeWire GUI volume control
      nautilus        # file manager (GTK)
      gnome-themes-extra  # themes for GTK apps running under Hyprland
      adwaita-icon-theme
    ];

    # ── GTK theme (for GTK apps running under Hyprland) ──────────────────────────
    # gtk.theme is set by catppuccin.nix when catppuccin is in the feature list.
    # Only set icon/cursor here; avoid conflicting with catppuccin's theme.name.
    gtk = {
      enable = true;
      iconTheme.name   = "Adwaita";
      cursorTheme.name = "Adwaita";
    };
  };
}
