# modules/home/catppuccin.nix
# Catppuccin Mocha theming for the Hyprland desktop stack.
# Uses catppuccin/nix (github:catppuccin/nix) home-manager module, which is
# injected into every HM configuration by modules/_lib/nixos-host.nix.
#
# catppuccin.waybar mode: "prependImport" (default) — prepends a catppuccin
# @import to programs.waybar.style, so our font/layout CSS in hyprland.nix
# continues to apply on top of catppuccin colours.
#
# catppuccin.enableReleaseCheck: set to false because we're on nixos-24.11 and
# catppuccin/nix targets 25.05+; the check produces a noisy eval warning that
# doesn't affect functionality.
{ ... }:

{
  flake.modules.homeManager.catppuccin = {
    catppuccin = {
      enable = true;
      flavor = "mocha";
      accent = "mauve";

      # Suppress the nixpkgs version mismatch warning — we're on 24.11, this is fine.
      enableReleaseCheck = false;
    };

    # Per-app opt-ins: only enable themes for apps that are actually installed
    # and configured via home-manager on this host. Enabling a catppuccin option
    # for an app that isn't managed by HM (e.g. programs.bat.enable = false) is
    # harmless but adds noise.

    # ── Waybar ────────────────────────────────────────────────────────────────────
    # mode = "prependImport": catppuccin CSS is @imported at the top of
    # programs.waybar.style — our font/layout rules in hyprland.nix still apply.
    catppuccin.waybar = {
      enable = true;
      mode   = "prependImport";
    };

    # ── Dunst ─────────────────────────────────────────────────────────────────────
    # Overrides the manual colour settings in hyprland.nix's services.dunst block.
    catppuccin.dunst.enable = true;

    # ── Rofi ──────────────────────────────────────────────────────────────────────
    # Replaces the "Arc-Dark" theme set in hyprland.nix.
    catppuccin.rofi.enable = true;

    # ── Hyprland window borders ───────────────────────────────────────────────────
    catppuccin.hyprland.enable = true;

    # ── GTK apps ──────────────────────────────────────────────────────────────────
    catppuccin.gtk.enable = true;

    # ── Kitty terminal ────────────────────────────────────────────────────────────
    # Note: kitty is installed as a package but not configured via programs.kitty.
    # Set programs.kitty.enable = true here so catppuccin can write its config.
    programs.kitty.enable = true;
    catppuccin.kitty.enable = true;

    # ── CLI tools ─────────────────────────────────────────────────────────────────
    catppuccin.bat.enable       = true;
    catppuccin.fzf.enable       = true;
    catppuccin.lsd.enable       = true;
    catppuccin.delta.enable     = true;  # git diff pager (configured in git.nix)
    catppuccin.starship.enable  = true;
    catppuccin.lazygit.enable   = true;
    catppuccin.k9s.enable       = true;
  };
}
