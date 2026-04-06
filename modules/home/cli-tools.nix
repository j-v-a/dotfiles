# modules/home/cli-tools.nix
# CLI tools shared across all devices.
{ ... }:

{
  flake.modules.homeManager.cli-tools = { pkgs, ... }: {
    home.packages = with pkgs; [
      # Search / navigation
      fd
      ripgrep
      bat
      eza
      lsd             # modern ls with icons and colours

      # Data / text processing
      jq
      yq-go
      imagemagick     # image manipulation CLI
      ast-grep        # structural code search

      # Git
      gh
      lazygit
      delta       # better git diffs

      # Network / http
      curl
      wget
      httpie

      # System monitoring / media
      btop            # interactive process/resource monitor
      fastfetch       # system info fetcher
      ffmpeg          # video/audio processing
      unimatrix       # matrix rain terminal screensaver

      # Misc utilities
      tree
      watch
      moreutils
      pwgen

      # Nix tooling
      nix-tree    # visualise nix derivation trees
    ];
  };
}
