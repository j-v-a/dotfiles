# modules/home/shell.nix
# Fish shell + Starship prompt — shared across all devices.
# Replaces: Oh My Zsh, Powerlevel10k, direnv hooks, pyenv init.
{ ... }:

{
  flake.modules.homeManager.shell = { pkgs, ... }: {
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

        # Tomorrow Night Bright color theme (declarative — overrides fish universal variable store)
        set -g fish_color_normal      normal
        set -g fish_color_command     c397d8
        set -g fish_color_keyword     c397d8
        set -g fish_color_param       7aa6da
        set -g fish_color_option      7aa6da
        set -g fish_color_quote       b9ca4a
        set -g fish_color_redirection 70c0b1
        set -g fish_color_end         c397d8
        set -g fish_color_error       d54e53
        set -g fish_color_comment     e7c547
        set -g fish_color_escape      00a6b2
        set -g fish_color_operator    00a6b2
        set -g fish_color_autosuggestion 969896
        set -g fish_color_valid_path  --underline
        set -g fish_color_cancel      -r
        set -g fish_color_search_match bryellow --background=brblack
        set -g fish_color_selection   white --bold --background=brblack
        set -g fish_color_history_current --bold
        set -g fish_color_host        normal
        set -g fish_color_host_remote yellow
        set -g fish_color_user        brgreen
        set -g fish_color_cwd         green
        set -g fish_color_cwd_root    red
        set -g fish_color_status      red
        set -g fish_color_match       --background=brblue

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
        cd  = "z";  # zoxide
      };
    };

    # Starship prompt — replaces both Oh My Zsh and Powerlevel10k
    programs.starship = {
      enable               = true;
      enableFishIntegration = true;
      settings = {
        add_newline = true;
      };
    };

    # zoxide — smarter cd (replaces z plugin)
    programs.zoxide = {
      enable               = true;
      enableFishIntegration = true;
    };

    # fzf — fuzzy finder
    programs.fzf = {
      enable               = true;
      enableFishIntegration = true;
    };

    # direnv — per-project env vars
    programs.direnv = {
      enable            = true;
      nix-direnv.enable = true;
    };

    # Let home-manager manage itself.
    programs.home-manager.enable = true;
  };
}
