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
          (mkt { publisher = "alexkrechik"; name = "cucumberautocomplete"; version = "3.1.0";       sha256 = "6f023067d700809714ca216b33daf1d05cc2c76f45e254503a78f0e66fdb3b6e"; })
          (mkt { publisher = "anthropic";   name = "claude-code";          version = "2.1.96";      sha256 = "7170e2e9ce2ef89e80164cd6c818c30fba91a3198d03657c025852101868d3d7"; })
          (mkt { publisher = "docker";      name = "docker";               version = "0.18.0";      sha256 = "6b95e564bee313160f873d473830a0bf0dbd2537fb0cdc9404541661efb87660"; })
          (mkt { publisher = "dotjoshjohnson"; name = "xml";               version = "2.5.1";       sha256 = "67004dbdb95df0fd662dc292ee21c3ab3c5cf13e8fd42f89432e78fba1379dec"; })
          (mkt { publisher = "dvirtz";      name = "parquet-viewer";       version = "3.0.1";       sha256 = "3348d1316e41b597602c478dddb8602ea206049337a69d957befe89496f110a3"; })
          (mkt { publisher = "github";      name = "copilot-chat";         version = "0.43.2026040705"; sha256 = "d357c1a6c5c80371b28c45ed1c87786e3071753aa64f4a3b20a55cb655ae023a"; })
          (mkt { publisher = "mechatroner"; name = "rainbow-csv";          version = "3.24.1";      sha256 = "c59a4aea924d5e7c6e75abb32628448bd5404915e2f3dfa19fbbdf177dea4606"; })
          (mkt { publisher = "ms-azuretools"; name = "vscode-containers";  version = "2.4.1";       sha256 = "3b0c492555b5e4c8af59579295b1503506ebc630e0a5778facf7feaf7a9bf80b"; })
          (mkt { publisher = "ms-python";   name = "vscode-python-envs";   version = "1.27.10931010"; sha256 = "9107efa565d5c93fc2b6e0586807a53272f7b636b188ecc7db1ee38c68d19545"; })
          (mkt { publisher = "ms-vscode-remote"; name = "remote-containers"; version = "0.452.0";   sha256 = "25cb3d98907dbf1b5304dc608f12e8671dbe02a618c9691e115b1937b19402d0"; })
          (mkt { publisher = "ms-vscode";   name = "vscode-typescript-next"; version = "6.0.20260401"; sha256 = "9f919242a18f26fdfdc4819c2875282a39517a8e1cbbf95e0cada1dad02f5e50"; })
          (mkt { publisher = "mthierman";   name = "theme-flexoki";        version = "0.0.9";       sha256 = "29ce948b90efff6f48a1d02be588ea4aead408d9d48730344e34864f25309337"; })
          (mkt { publisher = "nrwl";        name = "angular-console";      version = "18.91.0";     sha256 = "ad2d0f1ec8e20441ad257355ad033fbc6d97b177b472da2791945e3eacbef182"; })
          (mkt { publisher = "oven";        name = "bun-vscode";           version = "0.0.32";      sha256 = "565aee387885e7fc15855556d6baba0c473dd2edc8c1bc43feda535f2a610fe5"; })
          (mkt { publisher = "tamasfe";     name = "even-better-toml";     version = "0.21.2";      sha256 = "21b8d66af4285eee31e21a4492f921ab36dffcd859a67f1115d2930274650808"; })
          (mkt { publisher = "tim-koehler"; name = "helm-intellisense";    version = "0.15.0";      sha256 = "4e5d17da3b604ec8dfdadbf20092c6c441ab98b5c009859612b70326e41883ea"; })
          (mkt { publisher = "tomoki1207";  name = "pdf";                  version = "1.2.2";       sha256 = "8b74658b36f0e11b4f92212ca1d449101dc0533a2a23de68872a99d24b113a9b"; })
          (mkt { publisher = "visualstudioexptteam"; name = "intellicode-api-usage-examples"; version = "0.2.9"; sha256 = "f31043f962c16b162df2fdfef25bd5d928aa57cf621388de428776907ecb3475"; })
          (mkt { publisher = "visualstudioexptteam"; name = "vscodeintellicode"; version = "1.3.2"; sha256 = "d6b2434a94a62f566ddc2a40f6b52be824b30504228dec9a7ce45f2d3b8c3442"; })
          (mkt { publisher = "vue";         name = "volar";                version = "3.2.6";       sha256 = "d51e4ddc98c9519fca3d85c6abf54ecdb326423d5fceb2bd1eb02303c25ad9ae"; })
          (mkt { publisher = "vunguyentuan"; name = "vscode-css-variables"; version = "2.8.3";      sha256 = "6458dc3da3b3fa9ffd4a1d32cd67b282949c5e665cb516380af517e56a65815b"; })
        ];
      };
    };
}
