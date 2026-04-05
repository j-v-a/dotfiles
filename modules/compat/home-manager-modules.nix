# modules/compat/home-manager-modules.nix
# Exports homeManagerModules.{common, darwin, linux} for consumption by dotfiles-private.
# dotfiles-private imports dotfiles.homeManagerModules.darwin for the work-mac host.
#
# These are composed from the individual feature modules defined in modules/home/.
# The darwin-specific language-managers config is inline here (mac-only shell hooks).
{ config, ... }:

let
  # Common features shared by every device (mac + linux).
  commonModules = [
    config.flake.modules.homeManager.shell
    config.flake.modules.homeManager.cli-tools
    config.flake.modules.homeManager.git
    config.flake.modules.homeManager.editors
  ];

  # Shell hook wiring for nvm, pyenv, jenv, sdkman on macOS.
  # These tools remain imperative — Nix only provides the shell integration.
  darwinLanguageManagers = { ... }: {
    programs.fish.shellInit = ''
      # ── pyenv ──────────────────────────────────────────────────────────────
      if test -d $HOME/.pyenv
        set -gx PYENV_ROOT $HOME/.pyenv
        fish_add_path $PYENV_ROOT/bin
        if command -q pyenv
          pyenv init - fish | source
        end
      end

      # ── nvm ────────────────────────────────────────────────────────────────
      if test -d $HOME/.nvm
        set -gx NVM_DIR $HOME/.nvm
      end

      # ── jenv ───────────────────────────────────────────────────────────────
      if test -d $HOME/.jenv
        set -gx JENV_ROOT $HOME/.jenv
        fish_add_path $JENV_ROOT/bin
        if command -q jenv
          jenv init - fish | source 2>/dev/null
        end
      end

      # ── sdkman ─────────────────────────────────────────────────────────────
      if test -d $HOME/.sdkman
        set -gx SDKMAN_DIR $HOME/.sdkman
      end

      # ── rustup / cargo ─────────────────────────────────────────────────────
      if test -d $HOME/.cargo
        fish_add_path $HOME/.cargo/bin
      end
    '';
  };
in
{
  # homeManagerModules is not a standard flake-parts option — set via flake.* raw attrs.
  flake.homeManagerModules = {
    # common: shell + cli-tools + git + editors.
    # Used by: dotfiles-private (via darwin), standalone NixOS hosts.
    common = { imports = commonModules; };

    # darwin: common + mac language manager shell hooks.
    # Used by: dotfiles-private/hosts/work-mac/home.nix
    darwin = { imports = commonModules ++ [ darwinLanguageManagers ]; };

    # linux: common + linux-specific toolchains + desktop (HM side).
    # Currently not used by dotfiles-private (NixOS builds go through nixosConfigurations).
    # Exported for potential future use.
    linux = {
      imports = commonModules ++ [
        config.flake.modules.homeManager.linux-toolchains
        config.flake.modules.homeManager.hyprland
      ];
    };
  };
}
