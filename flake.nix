{
  description = "j-v-a dotfiles — NixOS + nix-darwin + home-manager (dendritic)";

  inputs = {
    # nixpkgs — canonical Linux/NixOS channel (nixos-24.11).
    # dotfiles-private follows this as its base and adds nixpkgs-darwin separately.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";

    # nixpkgs-darwin — macOS channel; kept here so dotfiles-private can follow it.
    # Not used directly in this flake (all hosts here are Linux).
    nixpkgs-darwin.url = "github:NixOS/nixpkgs/nixpkgs-24.11-darwin";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    import-tree.url = "github:vic/import-tree";

    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    catppuccin.url = "github:catppuccin/nix/v1.2.1";

    # Wallpaper collection — pinned to a specific commit for reproducibility.
    # Update with: nix flake update wallpapers
    wallpapers = {
      url = "github:teowelton/Wallpapers/202dc99b6a6d85759e8dd52e7e2a0edacecdba21";
      flake = false;
    };
  };

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } {
    imports = [
      inputs.flake-parts.flakeModules.modules
      (inputs.import-tree ./modules)
    ];
    # This flake only produces NixOS configs — no perSystem outputs.
    # Set to the union of all host systems so flake-parts doesn't complain.
    systems = [ "x86_64-linux" "aarch64-linux" ];
  };
}
