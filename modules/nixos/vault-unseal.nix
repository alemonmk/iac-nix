{
  self,
  config,
  lib,
  ...
}:
let
  cfg = config.services.vault-unseal;
in
{
  options.services.vault-unseal =
    let
      inherit (lib.options) mkOption mkEnableOption;
      inherit (lib.types) str;
    in
    {
      enable = mkEnableOption "Vault auto unsealing utility";

      configFile = mkOption {
        description = ''
          File containing configurations for vault-unseal.
          See [here](https://github.com/lrstanley/vault-unseal/blob/master/example.vault-unseal.yaml) for example.
        '';
        type = str;
      };
    };

  config.systemd.services.vault-unseal = lib.modules.mkIf cfg.enable {
    description = "Vault auto-unsealing utility";
    documentation = [ "https://github.com/lrstanley/vault-unseal" ];
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    serviceConfig = {
      LoadCredential = "config.yaml:${cfg.configFile}";
      DynamicUser = true;
      ExecStart = lib.strings.concatStringsSep " " [
        (lib.meta.getExe self.packages.x86_64-linux.vault-unseal)
        "--config /run/credentials/vault-unseal.service/config.yaml"
      ];
      Restart = "always";
      RestartSec = 10;
      TimeoutStopSec = 10;
      KillMode = "mixed";
      KillSignal = "SIGQUIT";
      PrivateDevices = true;
      ProtectHome = true;
      ProtectSystem = "full";
      PrivateTmp = true;
    };
  };
}
