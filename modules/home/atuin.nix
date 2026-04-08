# modules/home/atuin.nix
# Shell history via Atuin — local-only (no sync), replaces fzf-fish Ctrl+R.
{ ... }:

{
  flake.modules.homeManager.atuin = { ... }: {
    programs.atuin = {
      enable                = true;
      enableFishIntegration = true;
      settings = {
        auto_sync      = false;
        sync_frequency = "0";
        style          = "compact";
        inline_height  = 20;
        show_preview   = true;
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
