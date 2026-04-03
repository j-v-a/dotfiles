# home/modules/editors.nix
# Editor config — Neovim (Nix-pinned binary) + Zed (config symlinked).
# LazyVim manages Neovim plugins via lazy.nvim — not changed by Nix.
{ pkgs, ... }:

{
  # Pin Neovim version via Nix. LazyVim manages plugins independently.
  home.packages = [ pkgs.neovim ];

  # Neovim config lives at ~/.config/nvim — managed as a real directory, not a symlink.
  # LazyVim writes lazy-lock.json there, which requires a writable path (Nix store is read-only).
  # The canonical source is ~/dotfiles/config/nvim/ — sync manually when config changes:
  #   rsync -av ~/dotfiles/config/nvim/ ~/.config/nvim/
  # Do NOT use xdg.configFile here — it would make lazy-lock.json a read-only symlink.

  # Zed config symlinked from repo
  # xdg.configFile."zed".source = ../config/zed;    # uncomment in Step 14
}
