# modules/nixos/gaming.nix
# Gaming + media — personal workstation only.
# Unfree packages (steam, proton-ge-bin) are permitted by nixpkgs.config.allowUnfree in base.nix.
_:

{
  flake.modules.nixos.gaming = { pkgs, ... }: {
    # Steam — NixOS handles this specially (do not add as a plain package)
    programs.steam = {
      enable = true;
      # Proton-GE for better game compatibility
      extraCompatPackages = [ pkgs.proton-ge-bin ];
    };

    # 32-bit graphics support (required for Steam + older games). programs.steam also
    # sets this; kept explicit here as the single declaration (removed from nvidia.nix).
    hardware.graphics.enable32Bit = true;

    environment.systemPackages = with pkgs; [
      lutris
      mangohud # in-game performance overlay
    ];

    # GameMode — optimises system for gaming when games request it (also installs gamemoderun)
    programs.gamemode.enable = true;
  };
}
