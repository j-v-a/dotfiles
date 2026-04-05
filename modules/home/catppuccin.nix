# modules/home/catppuccin.nix
# Catppuccin Mocha theming for the Hyprland desktop stack.
# Uses catppuccin/nix (github:catppuccin/nix/v1.2.1) home-manager module,
# which is injected into every HM configuration by modules/_lib/nixos-host.nix.
#
# catppuccin.waybar mode: "prependImport" (default) — prepends a catppuccin
# @import to programs.waybar.style, so our font/layout CSS in hyprland.nix
# continues to apply on top of catppuccin colours.
{ ... }:

{
  flake.modules.homeManager.catppuccin = {
    catppuccin = {
      enable = true;
      flavor = "mocha";
      accent = "mauve";
    };

    # Per-app opt-ins: only enable themes for apps that are actually installed
    # and configured via home-manager on this host.

    # ── Waybar ────────────────────────────────────────────────────────────────────
    # mode = "prependImport": catppuccin CSS is @imported at the top of
    # programs.waybar.style — our font/layout rules in hyprland.nix still apply.
    catppuccin.waybar = {
      enable = true;
      mode   = "prependImport";
    };

    # ── Dunst ─────────────────────────────────────────────────────────────────────
    catppuccin.dunst.enable = true;

    # ── Rofi ──────────────────────────────────────────────────────────────────────
    catppuccin.rofi.enable = true;

    # ── Hyprland window borders ───────────────────────────────────────────────────
    catppuccin.hyprland.enable = true;

    # ── GTK apps ──────────────────────────────────────────────────────────────────
    catppuccin.gtk.enable = true;

    # ── Kitty terminal ────────────────────────────────────────────────────────────
    # kitty is installed as a package but not configured via programs.kitty.
    # Enable programs.kitty here so catppuccin can write its config file.
    programs.kitty.enable = true;
    catppuccin.kitty.enable = true;

    # ── CLI tools ─────────────────────────────────────────────────────────────────
    catppuccin.bat.enable      = true;
    catppuccin.fzf.enable      = true;
    catppuccin.lsd.enable      = true;
    catppuccin.delta.enable    = true;  # git diff pager (configured in git.nix)
    catppuccin.starship.enable = true;
    catppuccin.lazygit.enable  = true;
    catppuccin.k9s.enable      = true;
  };
}
