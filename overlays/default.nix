# overlays/default.nix
# Custom nixpkgs overlays. Add sparingly — every overlay affects the full
# package evaluation graph and can cause breakage on channel upgrades.
# Document the purpose of every overlay added here.
_final: _prev: {
  # Example (uncomment when needed):
  # my-patched-pkg = prev.my-pkg.overrideAttrs (_: { ... });
}
