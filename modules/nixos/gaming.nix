# modules/nixos/gaming.nix
# Gaming + media — personal workstation only.
# Requires allowUnfreePredicate to be set (done in base.nix).
{ ... }:

{
  flake.modules.nixos.gaming = { pkgs, ... }: {
    # Steam — NixOS handles this specially (do not add as a plain package)
    programs.steam = {
      enable = true;
      # Proton-GE for better game compatibility
      extraCompatPackages = [ pkgs.proton-ge-bin ];
    };

    # 32-bit graphics support (required for Steam + older games)
    hardware.graphics.enable32Bit = true;

    environment.systemPackages = with pkgs; [
      lutris
      mangohud   # in-game performance overlay
      gamemode   # game performance optimisation daemon
    ];

    # GameMode — optimises system for gaming when games request it
    programs.gamemode.enable = true;
  };
}
