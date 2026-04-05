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

        # Flexoki Dark color theme (declarative — overrides fish universal variable store)
        # Palette: https://stephango.com/flexoki — dark mode, 400-series accents
        set -g fish_color_normal      cecdc3  # tx  — primary text
        set -g fish_color_command     da702c  # or  — functions → orange-400
        set -g fish_color_keyword     879a39  # gr  — keywords  → green-400
        set -g fish_color_param       4385be  # bl  — variables → blue-400
        set -g fish_color_option      4385be  # bl  — flags/options
        set -g fish_color_quote       3aa99f  # cy  — strings   → cyan-400
        set -g fish_color_redirection 878580  # tx-2 — punctuation/operators
        set -g fish_color_end         878580  # tx-2 — separators
        set -g fish_color_error       d14d41  # re  — errors    → red-400
        set -g fish_color_comment     575653  # tx-3 — faint text/comments → base-700
        set -g fish_color_escape      ce5d97  # ma  — lang features → magenta-400
        set -g fish_color_operator    878580  # tx-2 — operators
        set -g fish_color_autosuggestion 6f6e69  # base-600 — faint autosuggestions
        set -g fish_color_valid_path  --underline
        set -g fish_color_cancel      -r
        set -g fish_color_search_match --background=403e3c  # ui-2 — selected bg
        set -g fish_color_selection   cecdc3 --bold --background=403e3c
        set -g fish_color_history_current --bold
        set -g fish_color_host        normal
        set -g fish_color_host_remote 8b7ec8  # pu  — purple-400
        set -g fish_color_user        879a39  # gr  — green-400
        set -g fish_color_cwd         4385be  # bl  — blue-400
        set -g fish_color_cwd_root    d14d41  # re  — red-400
        set -g fish_color_status      d14d41  # re  — nonzero exit
        set -g fish_color_match       --background=343331  # ui — match bg

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
