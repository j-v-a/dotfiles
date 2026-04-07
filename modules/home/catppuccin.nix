# modules/home/catppuccin.nix
# Catppuccin Mocha theming for the Hyprland desktop stack.
# Uses catppuccin/nix home-manager module injected via nixos-host.nix.
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
    # catppuccin.gtk is NOT enabled: the upstream GTK port has been archived.
    # See https://github.com/catppuccin/gtk/issues/262
    # gtk.theme is set directly by the catppuccin module via gtk.theme.name.

    # ── Kitty terminal ────────────────────────────────────────────────────────────
    # programs.kitty is fully configured in hyprland.nix (enable + font + settings).
    # catppuccin only needs the theme opt-in; no separate enable needed here.
    catppuccin.kitty.enable = true;

    # ── CLI tools ─────────────────────────────────────────────────────────────────
    catppuccin.bat.enable      = true;
    catppuccin.fzf.enable      = true;
    catppuccin.delta.enable    = true;  # git diff pager (configured in git.nix)
    catppuccin.starship.enable = true;
    catppuccin.lazygit.enable  = true;
    catppuccin.k9s.enable      = true;
  };
}
