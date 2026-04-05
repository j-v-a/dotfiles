# modules/nixos/system-utils.nix
# System-level utilities and daemons for desktop responsiveness and phone integration.
{ ... }:

{
  flake.modules.nixos.system-utils = { ... }: {
    # Ananicy-cpp — process priority daemon.
    # Applies CPU/IO nice levels to improve UI responsiveness under load
    # (e.g. prevents compile jobs from starving the compositor).
    services.ananicy = {
      enable  = true;
      package = pkgs: pkgs.ananicy-cpp;   # use the C++ rewrite (faster, lower overhead)
    };

    # KDE Connect — phone/desktop integration (file transfer, notifications, clipboard).
    # Opens required firewall ports for device discovery and communication.
    programs.kdeconnect.enable = true;
  };
}
