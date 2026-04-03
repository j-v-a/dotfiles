{
  description = "j-v-a dotfiles — NixOS + nix-darwin + home-manager";

  inputs = {
    # macOS: nixpkgs-24.11-darwin (not nixos-24.11 — wrong channel for Darwin)
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-24.11-darwin";

    # NixOS devices: nixos-24.11 (not nixpkgs-24.11-darwin — wrong channel for Linux)
    nixpkgs-linux.url = "github:NixOS/nixpkgs/nixos-24.11";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      # home-manager follows the Darwin nixpkgs for the Mac build in dotfiles-private.
      # NixOS builds pass nixpkgs-linux explicitly via specialArgs.
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-linux, home-manager, nixos-hardware, sops-nix, ... } @ inputs:
    let
      lib = import ./lib { inherit (nixpkgs) lib; };
    in
    {
      # NixOS configs — personal devices only.
      # work-mac lives in dotfiles-private and imports from here.
      nixosConfigurations = {
        personal-workstation = lib.mkNixosHost {
          inherit inputs nixos-hardware sops-nix home-manager;
          nixpkgs = nixpkgs-linux;
          hostname = "personal-workstation";
          system = "x86_64-linux";
        };

        surface = lib.mkNixosHost {
          inherit inputs nixos-hardware sops-nix home-manager;
          nixpkgs = nixpkgs-linux;
          hostname = "surface";
          system = "x86_64-linux";
        };

        home-server = lib.mkNixosHost {
          inherit inputs nixos-hardware sops-nix home-manager;
          nixpkgs = nixpkgs-linux;
          hostname = "home-server";
          system = "x86_64-linux";
        };
      };

      # Exported home-manager modules — used by dotfiles-private for work-mac.
      homeManagerModules = {
        common = import ./home/common.nix;
        darwin = import ./home/darwin.nix;
        linux  = import ./home/linux.nix;
      };

      # Exported NixOS modules — used by dotfiles-private and NixOS hosts.
      nixosModules = {
        dev      = import ./modules/dev;
        desktop  = import ./modules/desktop;
        gaming   = import ./modules/gaming;
        homelab  = import ./modules/homelab;
      };
    };
}
