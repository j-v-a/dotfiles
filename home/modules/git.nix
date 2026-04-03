# home/modules/git.nix
# Git config — personal identity as default.
# Work identity (Wärtsilä) is applied via includeIf in dotfiles-private.
{ ... }:

{
  programs.git = {
    enable = true;

    userName  = "j-v-a";
    userEmail = "jvanameijden@gmail.com";

    extraConfig = {
      pull.rebase           = true;
      init.defaultBranch    = "main";
      push.autoSetupRemote  = true;

      # Better diffs with delta
      core.pager            = "delta";
      interactive.diffFilter = "delta --color-only";
      delta = {
        navigate    = true;
        side-by-side = true;
        line-numbers = true;
      };
      merge.conflictstyle   = "zdiff3";

      # 1Password credential helper (already in use — keeping it)
      credential.helper = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
    };

    ignores = [
      ".DS_Store"
      ".direnv"
      ".envrc"
      "*.local"
      ".env"
      ".env.*"
      "!.env.example"
    ];
  };
}
