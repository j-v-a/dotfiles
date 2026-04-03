# home/modules/editors.nix
# Editor config — Neovim (Nix-pinned binary) + Zed (config symlinked).
# LazyVim manages Neovim plugins via lazy.nvim — not changed by Nix.
{ pkgs, ... }:

{
  # Pin Neovim version via Nix. LazyVim manages plugins independently.
  home.packages = [ pkgs.neovim ];

  # Symlink nvim config from repo into ~/.config/nvim
  # Source: ~/dotfiles/config/nvim/ (populated in Step 10)
  # xdg.configFile."nvim".source = ../config/nvim;  # uncomment in Step 10

  # Zed config symlinked from repo
  # xdg.configFile."zed".source = ../config/zed;    # uncomment in Step 14
}
