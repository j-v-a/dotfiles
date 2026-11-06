# modules/home/catppuccin.nix
# Catppuccin Mocha theming for CLI tools (and any HM-managed app not themed by Noctalia).
# Uses catppuccin/nix home-manager module injected via nixos-host.nix.
#
# On Linux the desktop palette (kitty, GTK, Qt, Hyprland borders) is owned by Noctalia's
# templates (home/noctalia.nix), so the matching catppuccin targets are switched off there.
_:

{
  flake.modules.homeManager.catppuccin =
    { lib, pkgs, ... }:
    let
      inherit (pkgs.stdenv) isLinux;
    in
    {
      # `catppuccin.enable` turns on every port whose program is enabled via home-manager.
      catppuccin = {
        enable = true;
        flavor = "mocha";
        accent = "mauve";
      };

      # VS Code uses Flexoki Dark (vscode.nix, mkForce), so the catppuccin extension
      # was unused — and its pnpm build dependency is flagged insecure on 26.05.
      catppuccin.vscode.profiles.default.enable = false;

      # ── Hyprland window borders ───────────────────────────────────────────────────
      # Always off: the catppuccin port is Lua-only now (`colors._var = require(...)`),
      # which breaks our hyprlang config (runtime overlay "colors:_var:_type does not
      # exist"). On Linux the border colours come from Noctalia's hyprland template.
      catppuccin.hyprland.enable = false;

      # ── CLI tools ─────────────────────────────────────────────────────────────────
      catppuccin.bat.enable = true;
      catppuccin.fzf.enable = true;
      catppuccin.delta.enable = true; # git diff pager (programs.delta in git.nix)
      catppuccin.starship.enable = true;
      catppuccin.lazygit.enable = true;
      catppuccin.k9s.enable = true;

      # ── Noctalia-owned targets (Linux only) ───────────────────────────────────────
      # Noctalia renders kitty/GTK/Qt colours from its active palette; catppuccin writing
      # the same files would fight it. GTK has no catppuccin theme port anymore (archived
      # upstream) — only the Papirus folder recolour, which we drop for plain Papirus.
      # Cursor is Bibata (wayland-common.nix). The mkIf guards keep any other host unchanged.
      catppuccin.kitty.enable = lib.mkIf isLinux false;
      catppuccin.gtk.icon.enable = lib.mkIf isLinux false;
      catppuccin.kvantum.enable = lib.mkIf isLinux false;
      catppuccin.cursors.enable = lib.mkIf isLinux false;
    };
}
