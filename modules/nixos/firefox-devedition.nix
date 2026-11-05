# modules/nixos/firefox-devedition.nix
# Firefox Developer Edition, installed system-wide.
_:

{
  flake.modules.nixos.firefox-devedition = { pkgs, ... }: {
    # firefox-devedition cannot coexist with firefox in home-manager home.packages
    # (both install libmozavutil.so to the same profile path → collision).
    # Installing at system level avoids the merge conflict.
    environment.systemPackages = [ pkgs.firefox-devedition ];
  };
}
