# dotfiles

Declarative NixOS + home-manager configuration using flake-parts and the **dendritic pattern**: every `.nix` file is a flake-parts module, auto-imported via `import-tree`. Hosts compose features by name.

## Devices

| Host | Arch | Desktop |
|------|------|---------|
| **Missandei** | x86_64-linux | GNOME + Hyprland (UWSM), GDM session picker |

Planned: Surface Pro 7+ and a home server (Beelink S13).

## Structure

```
flake.nix              # flake-parts entrypoint
modules/
  flake/treefmt.nix    # `nix fmt` (nixfmt, deadnix, statix) + formatting check
  lib/nixos-host.nix   # host helper (wires NixOS + home-manager per user)
  hosts/missandei.nix  # feature list + stateVersion for this host
  _hardware/           # hardware-configuration (excluded from auto-import)
  nixos/               # NixOS system modules (base, nvidia, hyprland, gnome, dev, gaming, ...)
  home/                # home-manager modules (shell, cli-tools, git, editors, desktop-apps, ...)
config/                # app configs symlinked into $HOME (e.g. Zed settings.json)
secrets/               # sops-nix encrypted secrets (age)
```

## Principles

- **Declarative & deterministic** — all state defined in Nix; reproducible across rebuilds.
- **Modular** — one feature per file; hosts opt-in via feature lists.
- **Safe** — previous generations are always available for rollback.
- **Dendritic** — no manual imports; `import-tree` discovers modules from git-tracked files.

## Usage

```bash
# Rebuild locally (nh: progress tree + package diff; NH_FLAKE points here)
nh os switch            # or: sudo nixos-rebuild switch --flake .#missandei
nh os boot              # kernel / NVIDIA / session changes, then reboot

# Rebuild remotely (from Mac)
ssh -t missandei 'cd ~/dotfiles && git pull && nh os switch'

# Format before committing
nix fmt
```

CI (`.github/workflows/`): gitleaks history scan, `nix flake check`, full Missandei build; weekly `flake.lock` update PR.

## Related

- [`dotfiles-private`](https://github.com/j-v-a/dotfiles-private) — work Mac (nix-darwin); imports this repo's modules.
- Channel: `nixos-26.05` / `home-manager release-26.05`
