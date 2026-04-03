{
  description = "j-v-a dotfiles — NixOS + nix-darwin + home-manager";

  inputs = {
    # macOS: use nixpkgs-24.11-darwin (not nixos-24.11 — wrong channel for Darwin)
    # NixOS devices override this to nixos-24.11 in their own flake inputs
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-24.11-darwin";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, nixos-hardware, sops-nix, ... } @ inputs:
    let
      lib = import ./lib { inherit (nixpkgs) lib; };
    in
    {
      # NixOS configs — personal devices only.
      # work-mac lives in dotfiles-private and imports from here.
      nixosConfigurations = {
        personal-workstation = lib.mkNixosHost {
          inherit inputs nixos-hardware sops-nix;
          hostname = "personal-workstation";
          system = "x86_64-linux";
          nixpkgsChannel = "github:NixOS/nixpkgs/nixos-24.11";
        };

        surface = lib.mkNixosHost {
          inherit inputs nixos-hardware sops-nix;
          hostname = "surface";
          system = "x86_64-linux";
          nixpkgsChannel = "github:NixOS/nixpkgs/nixos-24.11";
        };

        home-server = lib.mkNixosHost {
          inherit inputs nixos-hardware sops-nix;
          hostname = "home-server";
          system = "x86_64-linux";
          nixpkgsChannel = "github:NixOS/nixpkgs/nixos-24.11";
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
