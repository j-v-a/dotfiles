# modules/home/editors.nix
# Editor config — Neovim (Nix-pinned binary) + Zed (settings.json symlinked).
# LazyVim manages Neovim plugins via lazy.nvim — not changed by Nix.
#
# `self` refers to the flake itself (the dotfiles repo root), passed as a
# specialArg by flake-parts automatically. It is used here to reference static
# config files stored in the repo (e.g. config/zed/settings.json) without
# copying them into the Nix store — xdg.configFile.source expects a store path,
# so "${self}/config/zed/settings.json" evaluates to the correct store path at
# build time. This is the correct pattern for read-only dotfiles that live in
# the repo root but are not managed as Nix packages.
#
# Neovim intentionally does NOT use this pattern: LazyVim writes lazy-lock.json
# into ~/.config/nvim/, which must be writable. Instead ~/.config/nvim is an
# out-of-store symlink to the live checkout ~/dotfiles/config/nvim (writable, and
# lazy-lock.json changes show up in git). Requires the repo at ~/dotfiles on every host.
# One-time migration: an existing real ~/.config/nvim directory blocks the link —
# HM moves it aside via backupFileExtension (NixOS: .hm-backup, darwin: .before-hm);
# if that backup already exists, remove/rename ~/.config/nvim manually first.
{ self, ... }:

{
  flake.modules.homeManager.editors =
    {
      pkgs,
      config,
      homeDirectory,
      ...
    }:
    {
      # Pin Neovim version via Nix. LazyVim manages plugins independently.
      home.packages = [ pkgs.neovim ];

      # System default is nano (NixOS/nix-darwin), which isn't installed — sops, git etc. use $EDITOR.
      home.sessionVariables = {
        EDITOR = "nvim";
        VISUAL = "nvim";
      };

      xdg.configFile."nvim".source =
        config.lib.file.mkOutOfStoreSymlink "${homeDirectory}/dotfiles/config/nvim";

      # Zed: symlink only settings.json — not the whole dir.
      # ~/.config/zed/ contains runtime files (conversations/, prompts-library-db) that must
      # remain writable. Symlinking the file individually keeps those writable alongside it.
      xdg.configFile."zed/settings.json".source = "${self}/config/zed/settings.json";
    };
}
