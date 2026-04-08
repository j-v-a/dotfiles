# modules/home/tmux.nix
# Tmux — terminal multiplexer. Prefix: C-a. vi keys. True colour for kitty.
{ ... }:

{
  flake.modules.homeManager.tmux = { ... }: {
    programs.tmux = {
      enable       = true;
      terminal     = "tmux-256color";
      historyLimit = 10000;
      keyMode      = "vi";
      mouse        = true;
      prefix       = "C-a";

      extraConfig = ''
        # True colour — kitty sets TERM=xterm-kitty; cover both common values
        set -ag terminal-overrides ",xterm-256color:RGB"
        set -ag terminal-overrides ",xterm-kitty:RGB"

        # Pane splitting: | = horizontal split, - = vertical split
        bind | split-window -h -c "#{pane_current_path}"
        bind - split-window -v -c "#{pane_current_path}"
        unbind '"'
        unbind %

        # Vim-style pane navigation
        bind h select-pane -L
        bind j select-pane -D
        bind k select-pane -U
        bind l select-pane -R

        # Reload config
        bind r source-file ~/.config/tmux/tmux.conf \; display "Config reloaded"

        # Status bar — minimal, complements Starship
        set -g status-style        "bg=default,fg=white"
        set -g status-left         ""
        set -g status-right        "#S #[fg=bright-black]| #[fg=white]%H:%M"
        set -g status-right-length 30

        # Window tabs
        set -g window-status-format         " #I:#W "
        set -g window-status-current-format " #I:#W "
        set -g window-status-current-style  "fg=purple,bold"

        # Window/pane numbering starts at 1; gaps close automatically
        set -g  base-index       1
        setw -g pane-base-index  1
        set -g  renumber-windows on

        # No bell
        set -g bell-action none
      '';
    };
  };
}
