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

    # Starship prompt — Pure preset
    programs.starship = {
      enable               = true;
      enableFishIntegration = true;
      settings = {
        format = "$username$hostname$directory$git_branch$git_state$git_status$cmd_duration$line_break$python$character";

        directory.style = "blue";

        character = {
          success_symbol = "[❯](purple)";
          error_symbol   = "[❯](red)";
          vimcmd_symbol  = "[❮](green)";
        };

        git_branch = {
          format = "[$branch]($style)";
          style  = "bright-black";
        };

        git_status = {
          format     = "[[(*$conflicted$untracked$modified$staged$renamed$deleted)](218) ($ahead_behind$stashed)]($style)";
          style      = "cyan";
          conflicted = "";
          untracked  = "";
          modified   = "";
          staged     = "";
          renamed    = "";
          deleted    = "";
          stashed    = "≡";
        };

        git_state = {
          format = ''(\[$state( $progress_current/$progress_total)]($style)) '';
          style  = "bright-black";
        };

        cmd_duration = {
          format = "[$duration]($style) ";
          style  = "yellow";
        };

        python = {
          format = "[$virtualenv]($style) ";
          style  = "bright-black";
        };
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
