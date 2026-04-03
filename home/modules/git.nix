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
      fetch.prune           = true;
      init.defaultBranch    = "main";
      push.autoSetupRemote  = true;

      core = {
        pager    = "delta";
        autocrlf = "input";
      };

      interactive.diffFilter = "delta --color-only";
      delta = {
        navigate     = true;
        side-by-side = true;
        line-numbers = true;
      };
      merge.conflictstyle = "zdiff3";
      diff.colormoved     = "zebra";

      # 1Password credential helper
      credential.helper = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";

      # git-lfs
      filter.lfs = {
        clean    = "git-lfs clean -- %f";
        smudge   = "git-lfs smudge -- %f";
        process  = "git-lfs filter-process";
        required = true;
      };

      # Trust the wdcu repo (was in old ~/.gitconfig)
      safe.directory = "/Users/jva082/Projects/wdcu";
    };

    ignores = [
      # macOS
      ".DS_Store"
      # JetBrains IDEs
      ".idea/"
      # Node
      "npm-debug.log"
      "*.log"
      # Nix / direnv
      ".direnv"
      ".envrc"
      # Secrets
      ".env"
      ".env.*"
      "!.env.example"
      "*.local"
    ];
  };
}
