# modules/home/mac-shell-env.nix
# macOS-only home-manager config: shell hooks for imperative language managers.
# On macOS, nvm/pyenv/jenv/sdkman/rustup are installed and upgraded imperatively
# (not via Nix) to stay compatible with Wärtsilä tooling and version churn.
# This module provides the Fish shell integration so they appear on PATH.
{ ... }:

{
  flake.modules.homeManager.mac-shell-env = { ... }: {
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

      # ── asdf shims ────────────────────────────────────────────────────────
      if test -d $HOME/.asdf/shims
        fish_add_path $HOME/.asdf/shims
      end

      # ── asdf dotnet ────────────────────────────────────────────────────────
      if test -f $HOME/.asdf/plugins/dotnet/set-dotnet-env.fish
        source $HOME/.asdf/plugins/dotnet/set-dotnet-env.fish
      end
    '';
  };
}
