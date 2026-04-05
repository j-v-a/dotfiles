{
  description = "j-v-a dotfiles — NixOS + nix-darwin + home-manager (dendritic)";

  inputs = {
    # macOS: nixpkgs-24.11-darwin (not nixos-24.11 — wrong channel for Darwin)
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-24.11-darwin";

    # NixOS devices: nixos-24.11 (not nixpkgs-24.11-darwin — wrong channel for Linux)
    nixpkgs-linux.url = "github:NixOS/nixpkgs/nixos-24.11";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      # home-manager follows the Darwin nixpkgs for the Mac build in dotfiles-private.
      # NixOS builds pass nixpkgs-linux explicitly via the flake-parts module.
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

    catppuccin.url = "github:catppuccin/nix/release-25.05";
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
