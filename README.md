# dotfiles

Declarative NixOS + home-manager configuration using flake-parts and the **dendritic pattern**: every `.nix` file is a flake-parts module, auto-imported via `import-tree`. Hosts compose features by name.

## Devices

| Host | Arch | Desktop |
|------|------|---------|
| **Missandei** | x86_64-linux | Hyprland + GNOME (GDM) |

Surface Pro 7+ and a home server are planned future hosts.

## Structure

```
flake.nix              # flake-parts entrypoint
modules/
  lib/nixos-host.nix   # host helper (wires NixOS + home-manager per user)
  hosts/missandei.nix  # feature list for this host
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
# Rebuild locally
sudo nixos-rebuild switch --flake .#missandei

# Rebuild remotely (from Mac)
ssh -t missandei 'cd ~/dotfiles && git pull && sudo nixos-rebuild switch --flake .#missandei'
```

## Related

- [`dotfiles-private`](https://github.com/j-v-a/dotfiles-private) — work Mac (nix-darwin); imports this repo's modules.
- Channel: `nixos-26.05` / `home-manager release-26.05`
