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
      if command -q pyenv
        pyenv init - fish | source
      end
    end

    # ── nvm ────────────────────────────────────────────────────────────────
    # nvm is managed by Homebrew (homebrew.nix). It is a bash script and has
    # no native Fish integration. Two options:
    #
    #   Option A (current): use Homebrew's node formula directly and avoid nvm
    #             in Fish — nvm.fish (jorgebucaran) is not in nixpkgs fishPlugins.
    #
    #   Option B: install nvm.fish via Fisher (imperative, outside Nix):
    #             fisher install jorgebucaran/nvm.fish
    #             Then set NVM_DIR and use `nvm use <version>` natively in Fish.
    #
    # Until nvm.fish is adopted, Node version switching in Fish requires
    # opening a bash subshell or using `fnm` (faster, native Fish support,
    # available in nixpkgs) as a drop-in alternative.
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
