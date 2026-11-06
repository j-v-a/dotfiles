{
  description = "j-v-a dotfiles — NixOS + nix-darwin + home-manager (dendritic)";

  inputs = {
    # nixpkgs — canonical Linux/NixOS channel (nixos-26.05).
    # dotfiles-private follows this as its base and adds nixpkgs-darwin separately.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    # nixpkgs-darwin — macOS channel. Consumed by dotfiles-private
    # (nixpkgs.follows = "dotfiles/nixpkgs-darwin"); not used directly in this flake.
    nixpkgs-darwin.url = "github:NixOS/nixpkgs/nixpkgs-26.05-darwin";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware";
    nixos-hardware.inputs.nixpkgs.follows = "nixpkgs";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    import-tree.url = "github:vic/import-tree";

    # `nix fmt` / formatting check (modules/flake/treefmt.nix).
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Prebuilt nix-index database + comma (used by home/cli-tools.nix).
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
    };

    catppuccin = {
      url = "github:catppuccin/nix/v26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Noctalia — Wayland desktop shell for Hyprland: bar, notifications, lock, idle,
    # wallpaper, polkit agent, OSD (home/noctalia.nix). Following our nixpkgs means
    # noctalia.cachix.org hits are unlikely; it then builds locally (small C++ project).
    noctalia = {
      url = "github:noctalia-dev/noctalia";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Walker launcher + its Elephant data-provider backend (home/walker.nix).
    # elephant keeps its own nixpkgs: it needs buildGo127Module, which nixos-26.05 lacks.
    elephant.url = "github:abenz1267/elephant";
    walker = {
      url = "github:abenz1267/walker";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.elephant.follows = "elephant";
    };

    # Wallpaper collection — pinned to a specific commit for reproducibility.
    # Update with: nix flake update wallpapers
    wallpapers = {
      url = "github:teowelton/Wallpapers/202dc99b6a6d85759e8dd52e7e2a0edacecdba21";
      flake = false;
    };
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.flake-parts.flakeModules.modules
        (inputs.import-tree ./modules)
      ];
      # perSystem outputs (formatter, checks) only; aarch64-darwin so `nix fmt` works on the Mac.
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];
    };
}
