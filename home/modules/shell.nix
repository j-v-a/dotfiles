# home/modules/shell.nix
# Fish shell + Starship prompt — shared across all devices.
# Replaces: Oh My Zsh, Powerlevel10k, 3x direnv hooks, 3x pyenv init.
{ pkgs, ... }:

{
  programs.fish = {
    enable = true;

    # Plugins managed by home-manager (no fisher needed)
    plugins = [
      { name = "fzf-fish"; src = pkgs.fishPlugins.fzf-fish.src; }
      { name = "autopair"; src = pkgs.fishPlugins.autopair.src; }
    ];

    # Shell init — runs on every interactive shell start
    interactiveShellInit = ''
      # Suppress the default greeting
      set -g fish_greeting

      # direnv hook (single, clean — replaces 3x zsh hook)
      direnv hook fish | source
    '';

    # Aliases — ported from ~/.bash/aliases.sh and .zshrc
    # Expand as migration progresses (Step 7)
    shellAliases = {
      ls  = "eza --icons";
      ll  = "eza -la --icons --git";
      lt  = "eza --tree --icons -L 2";
      cat = "bat";
      cd  = "z";        # zoxide
    };
  };

  # Starship prompt — replaces both Oh My Zsh and Powerlevel10k
  programs.starship = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      add_newline = true;
      # Customise starship.toml here, or leave defaults — looks great out of the box
    };
  };

  # zoxide — smarter cd (replaces z plugin)
  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
  };

  # fzf — fuzzy finder
  programs.fzf = {
    enable = true;
    enableFishIntegration = true;
  };

  # direnv — per-project env vars
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;  # nix-direnv for fast nix shells
  };
}
