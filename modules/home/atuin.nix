# modules/home/atuin.nix
# Shell history via Atuin — local-only (no sync), replaces fzf-fish Ctrl+R.
_:

{
  flake.modules.homeManager.atuin = _: {
    programs.atuin = {
      enable = true;
      enableFishIntegration = true;
      settings = {
        auto_sync = false;
        sync_frequency = "0";
        style = "compact";
        inline_height = 20;
        show_preview = true;
        history_filter = [
          "^ls"
          "^ll"
          "^lt"
          "^cd"
          "^clear"
          "^exit"
          "^ "
        ];
      };
    };
  };
}
