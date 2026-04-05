# home/modules/desktop.nix
# Hyprland user-level configuration — personal workstation only.
# System-level Hyprland enablement is in modules/desktop/hyprland.nix.
# This file manages: Hyprland config, waybar, rofi, desktop packages.
{ pkgs, ... }:

{
  # ── Hyprland user config ───────────────────────────────────────────────────────
  # home-manager manages ~/.config/hypr/hyprland.conf as a symlink.
  # For complex configs use wayland.windowManager.hyprland.settings (nix-native)
  # or .extraConfig (raw HCL string). Using extraConfig here for readability.
  wayland.windowManager.hyprland = {
    enable = true;

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

      exec-once = [
        "waybar"                     # status bar
        "dunst"                      # notification daemon
      ];

      input = {
        kb_layout = "us";
        follow_mouse = 1;
        sensitivity = 0;
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
          size = 3;
          passes = 1;
        };
      };

      animations.enabled = true;

      dwindle = {
        pseudotile        = true;
        preserve_split    = true;
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
    # Minimal working config; customise after first boot.
    settings = [{
      layer  = "top";
      position = "top";
      modules-left   = [ "hyprland/workspaces" ];
      modules-center = [ "clock" ];
      modules-right  = [ "cpu" "memory" "temperature" "pulseaudio" "network" "battery" "tray" ];
      clock = { format = "%a %d %b  %H:%M"; tooltip = false; };
      cpu   = { format = " {usage}%"; interval = 5; };
      memory = { format = " {percentage}%"; interval = 5; };
      network = {
        format-wifi         = " {essid}";
        format-ethernet     = " {ifname}";
        format-disconnected = "⚠ Disconnected";
      };
      pulseaudio = {
        format        = "{icon} {volume}%";
        format-muted  = " muted";
        format-icons  = { default = [ "" "" "" ]; };
        on-click      = "pavucontrol";
      };
    }];
  };

  # ── Rofi (launcher) ───────────────────────────────────────────────────────────
  programs.rofi = {
    enable  = true;
    package = pkgs.rofi-wayland;
    theme   = "Arc-Dark";
  };

  # ── Desktop packages ──────────────────────────────────────────────────────────
  home.packages = with pkgs; [
    kitty            # terminal
    dunst            # notification daemon
    libnotify        # notify-send CLI
    grimblast        # screenshot (wlr-screencopy + slurp)
    wl-clipboard     # wl-copy / wl-paste
    pavucontrol      # PulseAudio/PipeWire GUI volume control
    nautilus         # file manager (GTK)
    gnome-themes-extra  # themes for GTK apps running under Hyprland
    adwaita-icon-theme
  ];

  # ── GTK theme (for GTK apps running under Hyprland) ──────────────────────────
  gtk = {
    enable = true;
    theme.name        = "Adwaita-dark";
    iconTheme.name    = "Adwaita";
    cursorTheme.name  = "Adwaita";
  };
}
