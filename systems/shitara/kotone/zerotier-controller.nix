{ config, ... }:
{
  services.zerotierone.localConf.settings.allowManagementFrom = [
    "10.85.183.0/24"
    "10.91.145.32/28"
  ];

  networking.nftables.tables.global.content =
    let
      zerotierPort = toString config.services.zerotierone.port;
    in
    ''
      chain overlay-input {
        iifname "ztinv*" ip daddr 10.85.183.6 tcp dport ${zerotierPort} counter accept
      }
    '';
}
