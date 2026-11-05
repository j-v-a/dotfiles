# modules/flake/treefmt.nix
# `nix fmt` + `checks.<system>.treefmt` (run by `nix flake check` in CI).
# nixfmt formats; deadnix removes unused bindings; statix fixes anti-patterns.
{ inputs, ... }:

{
  imports = [ inputs.treefmt-nix.flakeModule ];

  perSystem = {
    treefmt = {
      projectRootFile = "flake.nix";
      programs.nixfmt.enable = true;
      programs.deadnix.enable = true;
      programs.statix.enable = true;
    };
  };
}
