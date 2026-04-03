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

      # 1Password git credential helper for GitHub HTTPS operations (gh CLI auth).
      # op-ssh-sign is the SSH *signing* binary — it is NOT a credential helper.
      # The correct helper is the op plugin that proxies gh auth git-credential.
      "credential \"https://github.com/\"".helper = "!op plugin run -- gh auth git-credential";

      # Rewrite git:// (unauthenticated, deprecated) to https:// everywhere.
      "url \"https://\"".insteadOf = "git://";

      # git-lfs
      filter.lfs = {
        clean    = "git-lfs clean -- %f";
        smudge   = "git-lfs smudge -- %f";
        process  = "git-lfs filter-process";
        required = true;
      };
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
