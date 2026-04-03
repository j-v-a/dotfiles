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

      # Homebrew — macOS only. nix-darwin sets up Homebrew shellenv for bash/zsh but not fish.
      # On Linux /opt/homebrew does not exist; test first to avoid errors.
      if test -d /opt/homebrew/bin
        fish_add_path /opt/homebrew/bin
        fish_add_path /opt/homebrew/sbin
      end

      # direnv hook is injected automatically by programs.direnv.enable — no manual source needed.
    '';

    # Aliases — ported from ~/.bash/aliases.sh and .zshrc
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
    nix-direnv.enable = true;
  };
}
