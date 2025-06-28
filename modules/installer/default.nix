{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.unattendedInstaller =
    let
      inherit (lib) mkEnableOption mkOption;
      inherit (lib.types) attrs str;
    in
    {
      enable = mkEnableOption "Unattended installation service, for installing NixOS with disko on boot.";
      target = mkOption {
        type = attrs;
        description = "A NixOS system attrset (nixosSystem), required even though you want to install a flake. Should at least contain a Disko partitioning layout.";
        example = "self.nixosConfigurations.<machine>";
      };
      flake = mkOption {
        type = str;
        description = "Flake uri to install, which avoids full target toplevel from being included in store on installer. Needs to be in the format `/path/to/flake#machine-name`.";
        example = "github:some/where#machine";
      };
      preDisko = mkOption {
        type = str;
        description = "Command(s) to run before disko runs.";
        default = "";
      };
      postDisko = mkOption {
        type = str;
        description = "Command(s) to run after disko runs.";
        default = "";
      };
      preInstall = mkOption {
        type = str;
        description = "Command(s) to run before nix-install.";
        default = "";
      };
      postInstall = mkOption {
        type = str;
        description = "Command(s) to run after nix-install.";
        default = "";
      };
    };
  config = lib.mkIf config.unattendedInstaller.enable {
    systemd.services = {
      unattended-installer-progress = {
        wantedBy = [ "multi-user.target" ];
        unitConfig = {
          After = [ "getty.target" ];
          Conflicts = [ "getty@tty8.service" ];
        };
        script = ''
          set -xeufo pipefail
          ${pkgs.coreutils}/bin/env -i ${pkgs.tmux}/bin/tmux start \; show -g
          ${pkgs.tmux}/bin/tmux new-session -d -s unattended-installer /bin/sh -lc 'journalctl -fo cat -u unattended-installer.service | ${pkgs.nix-output-monitor}/bin/nom --json; /bin/sh'
          ${pkgs.kbd}/bin/openvt -v --wait --login --console=8 --force --switch -- ${pkgs.coreutils}/bin/env -i TERM=linux ${pkgs.tmux}/bin/tmux attach-session -t unattended-installer
        '';
      };
      unattended-installer = {
        wantedBy = [ "network-online.target" ];
        path = [
          "/run/wrappers"
          "/run/current-system/sw"
        ];
        script =
          let
            inherit (lib) elemAt split;
            a = elemAt (split "^([^#]*)#(.*)$" config.unattendedInstaller.flake) 1;
            flake-uri-for-nix-build = "${elemAt a 0}#nixosConfigurations.${elemAt a 1}.config.system.build.toplevel";
          in
          ''
            set -xeufo pipefail
            trap 'echo Installation failed!' EXIT
            ${config.unattendedInstaller.preDisko}
            echo Wiping and formatting disks, and then mounting to /mnt, using disko
            ${config.unattendedInstaller.target.config.system.build.diskoScript}
            ${config.unattendedInstaller.postDisko}

            ${config.unattendedInstaller.preInstall}
            echo Building and installing NixOS
            ${''
              # Flake install
              ${pkgs.nix}/bin/nix build --extra-experimental-features 'nix-command flakes' -v --show-trace --no-link --log-format internal-json ${flake-uri-for-nix-build}
              ${pkgs.nixos-install}/bin/nixos-install --no-channel-copy --no-root-password --flake ${config.unattendedInstaller.flake}
            ''}
            ${config.unattendedInstaller.postInstall}
            trap - EXIT
            echo Installation seems successful. Precautionary unmount
            ${pkgs.util-linux}/bin/umount -lfR /mnt || true
            echo Now running success action
            reboot
          '';
      };
    };
  };
}
