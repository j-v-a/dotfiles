# modules/home/git.nix
# Git config — personal identity as default.
# Work identity (Wärtsilä) is applied via includeIf in dotfiles-private.
{ ... }:

{
  flake.modules.homeManager.git = { ... }: {
    programs.git = {
      enable = true;

      userName  = "j-v-a";
      userEmail = "jvanameijden@gmail.com";

      extraConfig = {
        pull.rebase          = true;
        fetch.prune          = true;
        init.defaultBranch   = "main";
        push.autoSetupRemote = true;

        rerere.enabled = true;

        alias = {
          s  = "status";
          l  = "log --oneline --graph --decorate";
          aa = "add --all";
          ca = "commit --amend --no-edit";
          pb = "push --force-with-lease origin HEAD";
          d  = "diff";
          ds = "diff --staged";
          rc = "rebase --continue";
        };

        gpg = {
          format = "ssh";
          ssh.allowedSignersFile = "~/.ssh/allowed_signers";
        };
        commit.gpgsign = true;
        tag.gpgsign    = true;

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

        # GitHub credential helper: set per-device in device-specific config.
        # - macOS (work-mac): uses 1Password — set in dotfiles-private/modules/home/work-git.nix
        # - Linux (workstation): uses gh auth git-credential — set in linux-toolchains.nix
        # Leaving blank here avoids running op on Linux where op is not installed.

        # Rewrite git:// (unauthenticated, deprecated) to https:// everywhere.
        # git interprets [url "https://"] { insteadOf = "git://"; } as:
        # any URL beginning with git:// is rewritten to begin with https://
        "url \"https://\""."insteadOf" = "git://";

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
  };
}
