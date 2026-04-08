# modules/home/vscode.nix
# VSCode configuration — settings and extensions managed declaratively.
#
# Extensions sourced from two places:
#   1. pkgs.vscode-extensions.*  — built into nixpkgs, no SHA pinning needed
#   2. pkgs.vscode-utils.buildVscodeMarketplaceExtension — marketplace, SHA256 pinned
#
# To update a marketplace extension:
#   1. Find the new version via the marketplace or `code --list-extensions --show-versions`
#   2. Download the vsix:
#      curl -sL "https://marketplace.visualstudio.com/_apis/public/gallery/publishers/<pub>/vsextensions/<name>/<version>/vspackage" -o /tmp/ext.vsix
#   3. Get the new sha256: nix-hash --type sha256 --flat /tmp/ext.vsix
#   4. Update version + sha256 below
{ ... }:

{
  flake.modules.homeManager.vscode = { pkgs, lib, ... }:
    let
      mkt = { publisher, name, version, sha256 }:
        pkgs.vscode-utils.buildVscodeMarketplaceExtension {
          mktplcRef = { inherit publisher name version sha256; };
        };
    in
    {
      programs.vscode = {
        enable = true;

        # Allow VSCode to manage extensions outside the Nix store (e.g. workspace
        # recommendations). Set to false for a fully read-only extensions dir.
        mutableExtensionsDir = true;

        # ── Settings ──────────────────────────────────────────────────────────────
        userSettings = {
          "workbench.startupEditor"                    = "none";
          "workbench.colorTheme"                       = "Flexoki Dark";
          "window.systemColorTheme"                    = "dark";
          "files.autoSave"                             = "onFocusChange";
          "explorer.confirmDelete"                     = false;
          "eslint.format.enable"                       = true;
          "eslint.lintTask.enable"                     = true;
          "docker.extension.enableComposeLanguageServer" = false;
          "github.copilot.nextEditSuggestions.enabled" = true;
          "claudeCode.preferredLocation"               = "panel";
          "chat.agent.maxRequests"                     = 100;
          "terminal.integrated.fontFamily"             = "\"FiraCode Nerd Font Mono\"";
          "json.schemaDownload.trustedDomains" = {
            "https://schemastore.azurewebsites.net/" = true;
            "https://raw.githubusercontent.com/"     = true;
            "https://www.schemastore.org/"           = true;
            "https://json.schemastore.org/"          = true;
            "https://json-schema.org/"               = true;
            "https://biomejs.dev"                    = true;
          };
        };

        # ── Extensions ────────────────────────────────────────────────────────────
        extensions = with pkgs.vscode-extensions; [

          # ── From nixpkgs (no SHA pinning needed) ──────────────────────────────
          biomejs.biome                                    # Biome formatter/linter
          dbaeumer.vscode-eslint                           # ESLint
          ms-azuretools.vscode-docker                      # Docker
          ms-kubernetes-tools.vscode-kubernetes-tools      # Kubernetes
          ms-python.python                                 # Python
          ms-python.debugpy                                # Python debugger
          ms-python.vscode-pylance                         # Python language server
          redhat.java                                      # Java language support
          redhat.vscode-yaml                               # YAML
          redhat.vscode-xml                                # XML
          vscjava.vscode-java-debug                        # Java debugger
          vscjava.vscode-java-dependency                   # Java dependency viewer
          vscjava.vscode-java-pack                         # Java extension pack
          vscjava.vscode-java-test                         # Java test runner
          vscjava.vscode-maven                             # Maven
          vscjava.vscode-gradle                            # Gradle

          # ── From marketplace (SHA256 pinned) ──────────────────────────────────
          (mkt { publisher = "alexkrechik"; name = "cucumberautocomplete"; version = "3.1.0";       sha256 = "a8ffa04be33c8471e71f743f74f9432ca320a257dcefe6c1c374a9c3ef8afe10"; })
          (mkt { publisher = "anthropic";   name = "claude-code";          version = "2.1.96";      sha256 = "7170e2e9ce2ef89e80164cd6c818c30fba91a3198d03657c025852101868d3d7"; })
          (mkt { publisher = "docker";      name = "docker";               version = "0.18.0";      sha256 = "b1887278f1378419f0602fe98fc6b9fea1dbd49bf3bd4af9885a5c9fdaed605b"; })
          (mkt { publisher = "dotjoshjohnson"; name = "xml";               version = "2.5.1";       sha256 = "67004dbdb95df0fd662dc292ee21c3ab3c5cf13e8fd42f89432e78fba1379dec"; })
          (mkt { publisher = "dvirtz";      name = "parquet-viewer";       version = "3.0.1";       sha256 = "3348d1316e41b597602c478dddb8602ea206049337a69d957befe89496f110a3"; })
          (mkt { publisher = "github";      name = "copilot-chat";         version = "0.43.2026040705"; sha256 = "d357c1a6c5c80371b28c45ed1c87786e3071753aa64f4a3b20a55cb655ae023a"; })
          (mkt { publisher = "mechatroner"; name = "rainbow-csv";          version = "3.24.1";      sha256 = "c59a4aea924d5e7c6e75abb32628448bd5404915e2f3dfa19fbbdf177dea4606"; })
          (mkt { publisher = "ms-azuretools"; name = "vscode-containers";  version = "2.4.1";       sha256 = "7bfa166a235b3bbfa4a46775c7e384792f0ae46eecc53762fd392cf0fca0fcff"; })
          (mkt { publisher = "ms-python";   name = "vscode-python-envs";   version = "1.27.10931010"; sha256 = "38f0b638a2a09a5724d3d4fc97d22aa3370d539461b95df7937f487341db2bca"; })
          (mkt { publisher = "ms-vscode-remote"; name = "remote-containers"; version = "0.452.0";   sha256 = "0d0b788446e9e0d90688a86972a2a637e82f4a68c258b1cb82ab5fd14e0f41f8"; })
          (mkt { publisher = "ms-vscode";   name = "vscode-typescript-next"; version = "6.0.20260401"; sha256 = "0afa71314711cf5eae1a65936dd65d1e39f49a7cc667287c96d7d9b3f4972864"; })
          (mkt { publisher = "mthierman";   name = "theme-flexoki";        version = "0.0.9";       sha256 = "c28031710d113cd1dc3edc1ec651b7ece0f9d26d5352289d71c5a4c07efe5061"; })
          (mkt { publisher = "nrwl";        name = "angular-console";      version = "18.91.0";     sha256 = "f65277e012e2a26d7a6cc9378726355c4b69baf19a42e026649d9ae6c3f746d7"; })
          (mkt { publisher = "oven";        name = "bun-vscode";           version = "0.0.32";      sha256 = "ce843a3d3d765dcc28b984d932684ce232400fcc3c23007af097ac5ae39e281e"; })
          (mkt { publisher = "tamasfe";     name = "even-better-toml";     version = "0.21.2";      sha256 = "95fb32ea1b7a3a9bce45187eae1f53d39611aca0b9709bfe69ed6ac0815ebcf7"; })
          (mkt { publisher = "tim-koehler"; name = "helm-intellisense";    version = "0.15.0";      sha256 = "79a799e54c9ad9dee5c624cd0af6f4059144a50140c4d3f9f94127810ce49742"; })
          (mkt { publisher = "tomoki1207";  name = "pdf";                  version = "1.2.2";       sha256 = "4983fedc106935d605aef8a71dc406a0be20087fdc617947dd39f1ea74a3284c"; })
          (mkt { publisher = "visualstudioexptteam"; name = "intellicode-api-usage-examples"; version = "0.2.9"; sha256 = "a8ee4fc7ea6ae14e36a3724e937a2dd45e8109b5c4166f7e4302d46dad5f6855"; })
          (mkt { publisher = "visualstudioexptteam"; name = "vscodeintellicode"; version = "1.3.2"; sha256 = "d6b2434a94a62f566ddc2a40f6b52be824b30504228dec9a7ce45f2d3b8c3442"; })
          (mkt { publisher = "vue";         name = "volar";                version = "3.2.6";       sha256 = "a754a83f13476a3a25eaf0b6888b5c7ace14db67280c3bf8d176b44965ab7fab"; })
          (mkt { publisher = "vunguyentuan"; name = "vscode-css-variables"; version = "2.8.3";      sha256 = "626d41f15a730d2018b0fdffcb0ebae044675ec817e7d2e58a6efaa5118b471f"; })
        ];
      };
    };
}
