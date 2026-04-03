# home/modules/darwin/language-managers.nix
# Shell hook wiring for nvm, pyenv, jenv, sdkman on macOS.
# These tools remain imperative — Nix only provides the shell integration.
# Not imported on Linux devices (those use Nix-native toolchains).
{ ... }:

{
  programs.fish.shellInit = ''
    # ── pyenv ──────────────────────────────────────────────────────────────
    if test -d $HOME/.pyenv
      set -gx PYENV_ROOT $HOME/.pyenv
      fish_add_path $PYENV_ROOT/bin
      pyenv init - fish | source
    end

    # ── nvm ────────────────────────────────────────────────────────────────
    if test -d $HOME/.nvm
      set -gx NVM_DIR $HOME/.nvm
      # nvm is a bash script; source via bass or use nvm.fish plugin
      # Using nvm.fish plugin approach — install once with: fisher install jorgebucaran/nvm.fish
    end

    # ── jenv ───────────────────────────────────────────────────────────────
    if test -d $HOME/.jenv
      set -gx JENV_ROOT $HOME/.jenv
      fish_add_path $JENV_ROOT/bin
      jenv init - fish | source 2>/dev/null
    end

    # ── sdkman ─────────────────────────────────────────────────────────────
    # sdkman is bash-only; source via a wrapper function
    if test -d $HOME/.sdkman
      set -gx SDKMAN_DIR $HOME/.sdkman
    end

    # ── rustup / cargo ─────────────────────────────────────────────────────
    if test -d $HOME/.cargo
      fish_add_path $HOME/.cargo/bin
    end
  '';
}
