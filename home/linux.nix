# home/linux.nix
# Linux-specific home-manager config.
# Imports common + linux-specific modules.
{ pkgs, ... }:

{
  imports = [
    ./common.nix
  ];

  home.packages = with pkgs; [
    # Linux-only packages go here
  ];
}
