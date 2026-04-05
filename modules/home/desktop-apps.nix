# modules/home/desktop-apps.nix
# Linux-only: GUI desktop applications managed by Nix.
# On macOS these are managed by Homebrew casks (dotfiles-private/darwin/homebrew.nix).
#
# Unfree packages in this file that must be listed in base.nix allowUnfreePredicate:
#   vscode           — Microsoft license
#   obsidian         — proprietary
#   discord          — proprietary
#   spotify          — proprietary
#   zoom             — proprietary
#   slack            — proprietary
#   jetbrains.*      — JetBrains commercial license (each product listed separately)
{ ... }:

{
  flake.modules.homeManager.desktop-apps = { pkgs, ... }: {
    home.packages = with pkgs; [
      # ── Browsers ──────────────────────────────────────────────────────────────
      brave            # privacy-focused Chromium browser (free)

      # ── Communication ─────────────────────────────────────────────────────────
      discord          # voice/text/video chat (unfree)
      zoom-us          # video conferencing (unfree)
      slack            # team messaging (unfree)
      signal-desktop   # encrypted messenger (free)

      # ── Media ─────────────────────────────────────────────────────────────────
      spotify          # music streaming (unfree)

      # ── Productivity / notes ──────────────────────────────────────────────────
      obsidian         # markdown knowledge base (unfree)

      # ── Code editors / IDEs ───────────────────────────────────────────────────
      vscode           # Microsoft VS Code (unfree)
      zed-editor       # fast multiplayer code editor (free)
      ghostty          # GPU-accelerated terminal (free)

      # ── JetBrains IDEs ────────────────────────────────────────────────────────
      # All JetBrains IDEs are unfree (commercial license).
      # Listed individually so the allowUnfreePredicate can be explicit.
      jetbrains.idea-ultimate      # Java / JVM (IntelliJ IDEA Ultimate)
      jetbrains.pycharm-professional  # Python
      jetbrains.goland             # Go
      jetbrains.webstorm           # JavaScript / TypeScript
      jetbrains.datagrip           # Databases / SQL

      # ── VPN ───────────────────────────────────────────────────────────────────
      protonvpn-gui    # ProtonVPN client (free)
    ];
  };
}
