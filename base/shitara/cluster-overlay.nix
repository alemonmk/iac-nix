{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (config.networking) hostName;
  netConfig = import ./netconfigs.nix { inherit hostName; };
  loAddress = netConfig.lo;
  role = if config.services.strongswan-swanctl.enable then "border" else "internal";
in
{
  systemd.network = {
    config.networkConfig.IPv4Forwarding = true;
    networks."1-lo" = {
      matchConfig.Name = "lo";
      address = [ "${loAddress}/32" ];
    };
  };

  services = {
    zerotierone = {
      enable = true;
      localConf = {
        settings.interfacePrefixBlacklist = [
          "xfrm"
          "zt"
          "docker"
        ];
        settings.softwareUpdate = "disable";
      };
      joinNetworks = [ "1fdfc25cb4b9ceda" ];
    };

    bird = {
      enable = true;
      checkConfig = false;
      config =
        let
          commonFile = pkgs.replaceVarsWith {
            src = ../../blobs/shitara-overlay/common.conf;
            replacements = {
              inherit loAddress;
              inherit (config.networking) fqdn;
            };
          };
          bgpCfgFile = pkgs.replaceVarsWith {
            src = ../../blobs/shitara-overlay/bgp-cluster-${role}.conf;
            replacements = { inherit loAddress; };
          };
          ospfInClusterCfgFile = ../../blobs/shitara-overlay/ospf-cluster-internal.conf;
          ospfBorderCfgFile = ../../blobs/shitara-overlay/ospf-cluster-border.conf;
          borderIbgpCfgFile = lib.optionalString (
            role == "border"
          ) ../../blobs/shitara-overlay/bgp-border-${hostName}.conf;
        in
        lib.concatLines (
          [
            ''include "${commonFile.outPath}";''
            ''include "${bgpCfgFile.outPath}";''
          ]
          ++ lib.optionals (role == "border") [
            ''include "${ospfBorderCfgFile}";''
            ''include "${borderIbgpCfgFile}";''
          ]
          ++ lib.optionals (role == "internal") [
            ''include "${ospfInClusterCfgFile}";''
          ]
        );
    };

    prometheus.exporters.bird = {
      enable = true;
      listenAddress = loAddress;
      extraFlags = [
        "-proto.direct=false"
        "-proto.ospf=false"
        "-proto.static=false"
      ];
    };
  };

  systemd.services.bird.after = [ "vpn-route-gen.service" ];
  systemd.tmpfiles.settings = lib.optionalAttrs (role == "border") {
    "10-vpn-route-gen"."/etc/bird/reroute-via-vpn.conf".f = {
      mode = "0644";
      user = "root";
      group = "root";
    };
  };

  networking.nftables.tables.global.content =
    ''
      chain overlay-input {
        iifname "eth0" udp dport ${toString config.services.zerotierone.port} counter accept
        iifname "ztinv*" ip protocol 89 counter accept
        iifname "ztinv*" udp dport 3784 counter accept # BFD
        ip saddr 10.85.10.5 tcp dport ${toString config.services.prometheus.exporters.bird.port} counter accept
      }
    ''
    + lib.optionalString (role == "border") ''
      chain overlay-input {
        iifname "ztinv*" tcp dport bgp counter accept
      }
    ''
    + ''
      chain input {
        jump overlay-input
      }
    '';
}
