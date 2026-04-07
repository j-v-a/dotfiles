# modules/home/firefox.nix
# Firefox configuration with declaratively managed extensions.
#
# Extensions are sourced from pkgs.nur.repos.rycee.firefox-addons (NUR).
# NUR is wired in as a nixpkgs overlay in modules/lib/nixos-host.nix.
#
# firefox-devedition shares library files with firefox and cannot coexist in
# home.packages — it is installed via environment.systemPackages in nixos/base.nix.
# Extensions are applied to the default profile only (used by stable Firefox).
{ ... }:

{
  flake.modules.homeManager.firefox = { pkgs, ... }:
    let
      addons = pkgs.nur.repos.rycee.firefox-addons;
    in
    {
      programs.firefox = {
        enable = true;

        profiles.default = {
          id   = 0;
          name = "default";
          isDefault = true;

          extensions.packages = with addons; [
            onepassword-password-manager  # 1Password browser integration
            proton-pass                   # Proton Pass password manager
            web-clipper-obsidian          # Save pages to Obsidian vault
            react-devtools                # React debugging in devtools
            raindropio                    # Raindrop.io bookmark manager
          ];
        };
      };
    };
}
