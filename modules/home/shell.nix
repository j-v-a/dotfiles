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

        # LS_COLORS — used by plain `ls` inside containers/SSH where eza is unavailable.
        # vivid generates the value from a theme; only set if vivid is available.
        if command -q vivid
          set -gx LS_COLORS (vivid generate molokai)
        end

        # Disable fzf-fish history widget — Atuin handles Ctrl+R instead.
        set -gx FZF_FISH_DISABLE_KEYBINDING history

        # nixos-rebuild shortcuts — only meaningful on NixOS/Linux.
        if string match -q "Linux" (uname -s)
          alias nrs="sudo nixos-rebuild switch --flake ~/dotfiles#missandei"
          alias nrb="sudo nixos-rebuild build  --flake ~/dotfiles#missandei"
        end
      '';

      # Aliases
      shellAliases = {
        ls  = "eza --icons";
        ll  = "eza -la --icons --git";
        lt  = "eza --tree --icons -L 2";
        cat = "bat";

        # Git shortcuts
        gs  = "git status";
        gl  = "git log --oneline --graph --decorate";
        gaa = "git add --all";
        gca = "git commit --amend --no-edit";
        gpb = "git push --force-with-lease origin HEAD";
        gd  = "git diff";
        gds = "git diff --staged";
        grc = "git rebase --continue";

        # Nix shortcuts (shared — work on both Mac and Linux)
        nix-search = "nix search nixpkgs";
        nix-shell  = "nix shell nixpkgs#";
        nix-run    = "nix run nixpkgs#";
        nix-gc     = "nix-collect-garbage --delete-older-than 30d";
      };

      functions = {
        # git commit with auto Jira-ticket prefix from branch name
        gc = {
          description = "git commit with auto-ticket prefix from branch name";
          body = ''
            set branch (git rev-parse --abbrev-ref HEAD 2>/dev/null)
            set ticket (string match --regex --groups-only '[A-Z]+-[0-9]+' $branch)
            if test -n "$ticket"
              git commit -m "$ticket $argv"
            else
              git commit -m $argv
            end
          '';
        };

        # git switch with lockfile change warning
        gsw = {
          description = "git switch with lockfile change warning";
          body = ''
            git switch $argv
            set changed (git diff HEAD@{1} HEAD --name-only 2>/dev/null \
              | string match -r '(package-lock\.json|yarn\.lock|pnpm-lock\.yaml)')
            if test -n "$changed"
              echo "Lockfile changed — you may need to reinstall dependencies:"
              for f in $changed
                echo "  $f"
              end
            end
          '';
        };

        # Find TODO/FIXME/HACK/XXX comments in all tracked files
        git-todo = {
          description = "Find TODO/FIXME/HACK/XXX comments in tracked files";
          body = ''
            git ls-files | xargs rg --with-filename --line-number \
              --color=always 'TODO|FIXME|HACK|XXX|NOTE' 2>/dev/null
          '';
        };

        # Kill the process listening on a given port
        free-port = {
          description = "Kill the process listening on PORT";
          body = ''
            if test (count $argv) -lt 1
              echo "Usage: free-port <port>"
              return 1
            end
            set pid (lsof -ti tcp:$argv[1])
            if test -n "$pid"
              echo "Killing PID $pid on port $argv[1]"
              kill -9 $pid
            else
              echo "No process found on port $argv[1]"
            end
          '';
        };
      };
    };

    # Starship prompt — Pure preset
    programs.starship = {
      enable               = true;
      enableFishIntegration = true;
      settings = {
        format = "$os$username$hostname$directory$git_branch$git_state$git_status$cmd_duration$line_break$python$character";

        os = {
          disabled = false;
          format   = "[$symbol]($style) ";
          style    = "blue";
          symbols  = { NixOS = ""; };
        };

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
