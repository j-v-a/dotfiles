# modules/home/walker.nix
# Walker launcher (GTK4) + Elephant provider backend, Hyprland session only.
#   Super+R        app launcher (Return open, Shift+Return open+next, F1–F4 quick pick)
#   Super+Tab      window switcher (Elephant "windows" provider)
#   Super+.        symbols / emoji
#   Super+Shift+/  searchable list of every Hyprland bind (generated, always in sync)
{ inputs, ... }:

{
  flake.modules.nixos.walker = _: {
    # Upstream binary caches (walker README / flake nixConfig). Elephant builds against its
    # own nixpkgs pin and is the likely hit; walker follows ours and may build locally.
    nix.settings = {
      extra-substituters = [
        "https://walker.cachix.org"
        "https://walker-git.cachix.org"
      ];
      extra-trusted-public-keys = [
        "walker.cachix.org-1:fG8q+uAaMqhsMxWjwvk0IMb4mFPFLqHjuvfwQxE4oJM="
        "walker-git.cachix.org-1:vmC0ocfPWh0S/vRAQGtChuiZBTAe4wiKDeyyXM0/7pM="
      ];
    };
  };

  flake.modules.homeManager.walker =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      # ── Keybind cheatsheet ─────────────────────────────────────────────────────────
      # Rendered at build time from the merged Hyprland bind lists (hyprland.nix,
      # noctalia.nix, this file), one line per bind: "Super + Shift + W    exec …".
      hypr = config.wayland.windowManager.hyprland.settings;
      bindKinds = {
        bind = "";
        binde = "   (repeats)";
        bindl = "   (also when locked)";
        bindel = "   (repeats, also when locked)";
        bindm = "   (mouse drag)";
      };
      prettyMod =
        m:
        {
          "$mod" = "Super";
          SUPER = "Super";
          SHIFT = "Shift";
          CTRL = "Ctrl";
          CONTROL = "Ctrl";
          ALT = "Alt";
        }
        .${m} or m;
      prettyKey =
        k:
        {
          "mouse:272" = "Left mouse";
          "mouse:273" = "Right mouse";
          Return = "Enter";
          slash = "/";
          comma = ",";
          period = ".";
          left = "Left";
          right = "Right";
          up = "Up";
          down = "Down";
        }
        .${k} or k;
      padTo = n: s: s + lib.concatStrings (lib.replicate (lib.max 1 (n - lib.stringLength s)) " ");
      formatBind =
        suffix: line:
        let
          raw = lib.splitString "," line;
          mods = lib.filter (m: m != "") (lib.splitString " " (lib.trim (lib.elemAt raw 0)));
          key = prettyKey (lib.trim (lib.elemAt raw 1));
          dispatcher = lib.trim (lib.elemAt raw 2);
          args = lib.trim (lib.concatStringsSep "," (lib.drop 3 raw));
          combo = lib.concatStringsSep " + " (map prettyMod mods ++ [ key ]);
        in
        padTo 28 combo + lib.trim "${dispatcher} ${args}" + suffix;
      cheatsheet = pkgs.writeText "hyprland-keybinds.txt" (
        lib.concatStringsSep "\n" (
          lib.concatLists (
            lib.mapAttrsToList (kind: suffix: map (formatBind suffix) (hypr.${kind} or [ ])) bindKinds
          )
        )
        + "\n"
      );
      hyprKeybinds = pkgs.writeShellScriptBin "hypr-keybinds" ''
        walker --dmenu --placeholder "Hyprland keybinds" < ${cheatsheet} > /dev/null
      '';
    in
    {
      imports = [ inputs.walker.homeManagerModules.default ];

      programs.walker = {
        enable = true;
        # Resident GApplication service → near-instant open; also starts elephant.
        runAsService = true;

        # Merged by walker over its built-in defaults (resources/config.toml), which keep
        # the action hints (open / open+next …) and F1–F4 quick activation visible.
        config = {
          theme = "noctalia";
          force_keyboard_focus = true;
          selection_wrap = true;
          hide_action_hints = false;
          hide_quick_activation = false;
          keybinds.quick_activate = [
            "F1"
            "F2"
            "F3"
            "F4"
          ];
          providers = {
            default = [
              "desktopapplications"
              "calc"
              "menus"
              "websearch"
            ];
            max_results_provider.symbols = 100;
          };
        };

        # Own stylesheet (glass panel, after n3rsti's look). Colours are GTK named colours:
        # Noctalia's gtk4 template defines them in ~/.config/gtk-4.0/noctalia.css (user
        # priority, so it overrides the Catppuccin Mocha fallbacks below).
        themes.noctalia.style = ''
          @define-color window_bg_color #1e1e2e;
          @define-color window_fg_color #cdd6f4;
          @define-color accent_bg_color #cba6f7;
          @define-color error_bg_color #f38ba8;
          @define-color error_fg_color #11111b;

          * {
            all: unset;
            font-family: "Adwaita Sans", sans-serif;
          }

          .normal-icons { -gtk-icon-size: 16px; }
          .large-icons { -gtk-icon-size: 32px; }
          scrollbar { opacity: 0; }

          .box-wrapper {
            background: alpha(@window_bg_color, 0.6);
            color: @window_fg_color;
            padding: 20px;
            border-radius: 20px;
            border: 1px solid alpha(@accent_bg_color, 0.35);
            box-shadow: 0 8px 24px alpha(black, 0.35);
          }

          .input {
            background: alpha(@window_fg_color, 0.06);
            color: @window_fg_color;
            caret-color: @window_fg_color;
            padding: 10px 12px;
            border-radius: 12px;
          }
          .input placeholder { opacity: 0.5; }

          .list { color: @window_fg_color; }
          .item-box { padding: 10px; border-radius: 12px; }
          child:hover .item-box,
          child:selected .item-box { background: alpha(@accent_bg_color, 0.22); }
          .item-image { margin-right: 10px; }
          .item-subtext { font-size: 12px; opacity: 0.55; }

          .item-quick-activation {
            margin-left: 10px;
            padding: 4px 8px;
            border-radius: 6px;
            background: alpha(@accent_bg_color, 0.22);
            font-size: 12px;
          }

          .elephant-hint, .placeholder, .preview-box { color: alpha(@window_fg_color, 0.7); }
          .preview {
            padding: 10px;
            border-radius: 12px;
            border: 1px solid alpha(@accent_bg_color, 0.25);
          }
          .preview .large-icons { -gtk-icon-size: 64px; }

          .keybinds {
            padding-top: 10px;
            margin-top: 6px;
            border-top: 1px solid alpha(@window_fg_color, 0.1);
            font-size: 12px;
            color: @window_fg_color;
          }
          .keybind-button { opacity: 0.6; }
          .keybind-button:hover { opacity: 0.9; }
          .keybind-bind { font-weight: bold; opacity: 0.7; }
          .keybind-label {
            padding: 2px 6px;
            border-radius: 6px;
            border: 1px solid alpha(@window_fg_color, 0.3);
          }

          .calc .item-text { font-size: 24px; }
          .symbols .item-image { font-size: 24px; }

          .error {
            padding: 10px;
            border-radius: 12px;
            background: @error_bg_color;
            color: @error_fg_color;
          }
        '';
      };

      home.packages = [ hyprKeybinds ];

      wayland.windowManager.hyprland.settings = {
        bind = [
          "$mod, R, exec, walker"
          "$mod, Tab, exec, walker --provider windows"
          "$mod, period, exec, walker --provider symbols"
          "$mod SHIFT, slash, exec, hypr-keybinds"
        ];
        layerrule = [
          "blur on, ignore_alpha 0.2, no_anim on, match:namespace ^walker$"
        ];
      };

      # Same Hyprland-only gating as noctalia.nix: never start the launcher stack in GNOME.
      # mkForce replaces the modules' single WAYLAND_DISPLAY condition (kept in the list).
      systemd.user.services = lib.genAttrs [ "walker" "elephant" ] (_: {
        Unit.ConditionEnvironment = lib.mkForce [
          "WAYLAND_DISPLAY"
          "XDG_CURRENT_DESKTOP=Hyprland"
        ];
      });
    };
}
