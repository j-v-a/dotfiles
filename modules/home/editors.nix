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
# into ~/.config/nvim/, which requires the directory to be writable. Symlinking
# the whole nvim config dir would make it read-only (Nix store). Use rsync instead:
#   rsync -av ~/dotfiles/config/nvim/ ~/.config/nvim/
{ self, ... }:

{
  flake.modules.homeManager.editors = { pkgs, ... }: {
    # Pin Neovim version via Nix. LazyVim manages plugins independently.
    home.packages = [ pkgs.neovim ];

    # Zed: symlink only settings.json — not the whole dir.
    # ~/.config/zed/ contains runtime files (conversations/, prompts-library-db) that must
    # remain writable. Symlinking the file individually keeps those writable alongside it.
    xdg.configFile."zed/settings.json".source = "${self}/config/zed/settings.json";
  };
}
