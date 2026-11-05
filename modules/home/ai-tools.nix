# modules/home/ai-tools.nix
# AI coding assistant desktop apps — Linux only.
# Mac: OpenCode is installed via Homebrew cask (anomalyco/tap) in dotfiles-private.
#
# OpenCode is distributed as an Electron AppImage for Linux. We wrap it with
# appimageTools.wrapType2 so it integrates with the Nix store and PATH correctly.
_:

{
  flake.modules.homeManager.ai-tools =
    { pkgs, lib, ... }:
    let
      opencode-version = "1.19.5";
      opencode-src = pkgs.fetchurl {
        url = "https://github.com/anomalyco/opencode/releases/download/v${opencode-version}/opencode-desktop-linux-x86_64.AppImage";
        hash = "sha256-LFtTcihd/htcs6QcDhgTqHW4lc0JPHDjQX/YOP1giIM=";
      };
      opencode = pkgs.appimageTools.wrapType2 {
        pname = "opencode";
        version = opencode-version;
        src = opencode-src;
        extraPkgs = pkgs: [ pkgs.wayland ];
        extraArgs = "--ozone-platform=wayland --enable-features=WaylandWindowDecorations";
      };
    in
    lib.mkIf pkgs.stdenv.isLinux {
      home.packages = [ opencode ];

      # AppImage wrappers don't generate .desktop files automatically,
      # so rofi/app launchers can't find OpenCode. Add one manually.
      xdg.desktopEntries.opencode = {
        name = "OpenCode";
        exec = "opencode";
        comment = "AI coding assistant";
        categories = [
          "Development"
          "IDE"
        ];
        terminal = false;
      };
    };
}
