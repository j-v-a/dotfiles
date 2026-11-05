# modules/home/cli-tools.nix
# CLI tools shared across all devices.
{ inputs, ... }:

{
  flake.modules.homeManager.cli-tools = { pkgs, lib, ... }: {
    # Prebuilt nix-index database (weekly) + comma: `, <cmd>` runs any nixpkgs binary once.
    # Also provides the shell command-not-found handler.
    imports = [ inputs.nix-index-database.homeModules.nix-index ];
    programs.nix-index.enable = true;
    programs.nix-index-database.comma.enable = true;

    # nh on macOS (`nh darwin switch`); NixOS gets it system-wide via nixos/base.nix.
    # NH_FLAKE is set per host (dotfiles-private on the Mac).
    programs.nh.enable = lib.mkDefault pkgs.stdenv.isDarwin;

    home.packages = with pkgs; [
      # Search / navigation
      fd
      ripgrep
      bat
      eza
      lsd             # modern ls with icons and colours
      vivid           # generates LS_COLORS values from themes

      # Data / text processing
      jq
      yq-go
      imagemagick     # image manipulation CLI
      ast-grep        # structural code search

      # Dev tooling
      asdf-vm
      dotnet-sdk_10   # .NET 10 SDK (includes runtime and CLI)

      # Git
      gh
      lazygit
      delta       # better git diffs
      git-lfs     # large file storage (filters configured in git.nix)

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
      nvd         # diff two closures / generations
    ];
  };
}
