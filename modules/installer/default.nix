{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.unattendedInstaller =
    let
      inherit (lib.options) mkEnableOption mkOption;
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
        description = "Command(s) to run before nixos-install.";
        default = "";
      };
      postInstall = mkOption {
        type = str;
        description = "Command(s) to run after nixos-install.";
        default = "";
      };
    };
  config = lib.modules.mkIf config.unattendedInstaller.enable {
    systemd.services = {
      unattended-installer = {
        wantedBy = [ "multi-user.target" ];
        path = [
          "/run/wrappers"
          "/run/current-system/sw"
        ];
        unitConfig = {
          After = [ "getty.target" ];
          Conflicts = [ "getty@tty8.service" ];
        };
        serviceConfig = {
          TTYPath = "/dev/tty8";
          StandardInput = "tty";
          StandardOutput = "tty";
        };
        script =
          let
            inherit (lib) elemAt split;
            a = elemAt (split "^([^#]*)#(.*)$" config.unattendedInstaller.flake) 1;
            flake-uri-for-nix-build = "${elemAt a 0}#nixosConfigurations.${elemAt a 1}.config.system.build.toplevel";
            install-script = pkgs.writeShellApplication {
              name = "unattended-installer";
              text = ''
                trap 'echo Installation failed!' EXIT
                ${config.unattendedInstaller.preDisko}
                echo 'Wiping and formatting disks, and then mounting to /mnt, using disko'
                ${config.unattendedInstaller.target.config.system.build.diskoScript}
                ${config.unattendedInstaller.postDisko}

                ${config.unattendedInstaller.preInstall}
                echo 'Building and installing NixOS'
                ${''
                  # Flake install
                  nom build --show-trace --no-link ${flake-uri-for-nix-build}
                  nixos-install --no-channel-copy --no-root-password --flake ${config.unattendedInstaller.flake}
                ''}
                ${config.unattendedInstaller.postInstall}
                trap - EXIT
                echo 'Installation seems successful. Precautionary unmount'
                umount -lfR /mnt || true
                echo 'Now running success action'
                reboot
              '';
            };
          in
          ''
            set -xeufo pipefail
            openvt -v --wait --login --console=8 --force --switch -- ${lib.meta.getExe install-script}
          '';
      };
    };
  };
}
