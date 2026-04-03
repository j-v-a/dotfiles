# home/modules/cli-tools.nix
# CLI tools shared across all devices.
# These will be migrated from Homebrew incrementally (Phase 1 Step 9).
{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Search / navigation
    fd
    ripgrep
    bat
    eza
    zoxide

    # Data / text processing
    jq
    yq-go

    # Git
    gh
    lazygit
    delta        # better git diffs

    # Network / http
    curl
    wget
    httpie

    # Misc utilities
    tree
    watch
    moreutils
    pwgen

    # Nix tooling
    nix-tree     # visualise nix derivation trees
  ];
}
