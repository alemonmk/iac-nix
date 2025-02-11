# Adapted from github:chrillefkr/nixos-unattended-installer
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.unattendedInstaller;
in {
  options.unattendedInstaller = {
    # Quite necessary that this is disabled by default. Otherwise this project could be renamed "unintended-reinstaller" ;)
    enable = lib.mkEnableOption "Unattended installation service, for installing NixOS with disko on boot.";
    target = lib.mkOption {
      type = lib.types.attrs;
      description = "A NixOS system attrset (nixosSystem), required even though you want to install a flake. Should at least contain a Disko partitioning layout.";
      example = "self.nixosConfigurations.<machine>";
    };
    flake = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      description = "Flake uri to install, which avoids full target toplevel from being included in store on installer. Needs to be in the format `/path/to/flake#machine-name`.";
      example = "github:some/where#machine";
      default = null;
    };
    preDisko = lib.mkOption {
      type = lib.types.str;
      description = "Command(s) to run before disko runs.";
      default = "";
    };
    postDisko = lib.mkOption {
      type = lib.types.str;
      description = "Command(s) to run after disko runs.";
      default = "";
    };
    preInstall = lib.mkOption {
      type = lib.types.str;
      description = "Command(s) to run before nix-install.";
      default = "";
    };
    postInstall = lib.mkOption {
      type = lib.types.str;
      description = "Command(s) to run after nix-install.";
      default = "";
    };
  };
  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      systemd.services.unattended-installer-progress = {
        wantedBy = ["multi-user.target"];
        unitConfig = {
          After = ["getty.target"];
          Conflicts = ["getty@tty8.service"];
        };
        script = ''
          set -xeufo pipefail
          ${pkgs.coreutils}/bin/env -i ${pkgs.tmux}/bin/tmux start \; show -g
          ${pkgs.tmux}/bin/tmux new-session -d -s unattended-installer /bin/sh -lc 'journalctl -fo cat -u unattended-installer.service | ${pkgs.nix-output-monitor}/bin/nom --json; /bin/sh'
          ${pkgs.kbd}/bin/openvt -v --wait --login --console=8 --force --switch -- ${pkgs.coreutils}/bin/env -i TERM=linux ${pkgs.tmux}/bin/tmux attach-session -t unattended-installer
        '';
      };
    }
    {
      systemd.services.unattended-installer = {
        wantedBy = ["network-online.target"];
        path = [
          "/run/wrappers"
          "/run/current-system/sw"
        ];
        script = let
          a = builtins.elemAt (builtins.split "^([^#]*)#(.*)$" cfg.flake) 1;
          flake-uri-for-nix-build = "${builtins.elemAt a 0}#nixosConfigurations.${builtins.elemAt a 1}.config.system.build.toplevel";
        in ''
          set -xeufo pipefail
          trap 'echo Installation failed!' EXIT
          ${cfg.preDisko}
          echo Wiping and formatting disks, and then mounting to /mnt, using disko
          ${cfg.target.config.system.build.diskoScript}
          ${cfg.postDisko}

          ${cfg.preInstall}
          echo Building and installing NixOS
          ${
            if (builtins.isNull cfg.flake)
            then ''
              # Regular install from store
              ${pkgs.nixos-install-tools}/bin/nixos-install --no-channel-copy --no-root-password --system ${cfg.target.config.system.build.toplevel}
            ''
            else ''
              # Flake install
              ${pkgs.nix}/bin/nix build --extra-experimental-features 'nix-command flakes' -v --show-trace --no-link --log-format internal-json ${flake-uri-for-nix-build}
              ${pkgs.nixos-install-tools}/bin/nixos-install --no-channel-copy --no-root-password --flake ${cfg.flake}
            ''
          }
          ${cfg.postInstall}
          trap - EXIT
          echo Installation seems successful. Precautionary unmount
          ${pkgs.util-linux}/bin/umount -lfR /mnt || true
          echo Now running success action
          reboot
        '';
      };
    }
  ]);
}
