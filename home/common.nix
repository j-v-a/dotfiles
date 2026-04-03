# home/common.nix
# Home-manager config shared across ALL devices (mac + linux).
# Imported by both darwin.nix and linux.nix.
{ pkgs, ... }:

{
  imports = [
    ./modules/shell.nix
    ./modules/cli-tools.nix
    ./modules/git.nix
    ./modules/editors.nix
  ];

  # Let home-manager manage itself.
  programs.home-manager.enable = true;

  # Set once at first deploy — never change.
  home.stateVersion = "24.11";
}
