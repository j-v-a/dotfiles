# home/darwin.nix
# macOS-specific home-manager config.
# Imports common + mac-specific modules.
{ pkgs, ... }:

{
  imports = [
    ./common.nix
    ./modules/darwin/language-managers.nix
  ];

  # macOS-specific home packages (supplements Homebrew)
  home.packages = with pkgs; [
    # Add mac-only Nix packages here as migration progresses
  ];
}
