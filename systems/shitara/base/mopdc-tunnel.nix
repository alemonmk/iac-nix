{
  flakeRoot,
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib.strings) optionalString concatLines;
  inherit (lib.lists) optional optionals;
  inherit (lib.modules) mkIf mkAfter;
  inherit (pkgs) replaceVarsWith;
  netConfig = import ../../netconfigs.nix config.networking.hostName;
in
mkIf (netConfig ? pdc-tunnel) (
  let
    wanAddress = netConfig.wan.v4;
    localTunAddrV4 = netConfig.pdc-tunnel.local.v4;
    localTunAddrV6 = netConfig.pdc-tunnel.local.v6 or null;
    peerTunAddrV4 = netConfig.pdc-tunnel.peer.v4;
    peerTunAddrV6 = netConfig.pdc-tunnel.peer.v6 or null;
  in
  {
    systemd.network = {
      config.networkConfig.IPv6Forwarding = localTunAddrV6 != null;
      networks."2-eth0".xfrm = [ "xfrm0" ];
      networks."10-xfrm0" = {
        matchConfig.Name = "xfrm0";
        linkConfig.MTUBytes = 1400;
        address = [ "${localTunAddrV4}/31" ] ++ optional (localTunAddrV6 != null) "${localTunAddrV6}/64";
      };
      netdevs."10-xfrm0" = {
        netdevConfig = {
          Name = "xfrm0";
          Kind = "xfrm";
        };
        xfrmConfig.InterfaceId = netConfig.pdc-tunnel.xfrmId;
      };
    };

    sops.secrets.ipsec-psk.sopsFile = flakeRoot + /secrets/shitara/ipsec.yaml;

    services.strongswan-swanctl = {
      enable = true;
      strongswan.extraConfig = ''
        charon {
          install_routes = no
          install_virtual_ip = no
          make_before_break = yes
          send_vendor_id = yes
        }
      '';
      swanctl.connections."to-mo-pdc" = {
        version = 2;
        local."0" = {
          id = netConfig.pdc-tunnel.localId;
          auth = "psk";
        };
        local_addrs = [ wanAddress ];
        remote."0" = {
          auth = "psk";
          id = "@mo-n1.glb-tnsp.snct.rmntn.net";
        };
        remote_addrs = [ "%any" ];
        proposals = [ "aes256gcm16-prfsha384-ecp384" ];
        rekey_time = "8h";
        dpd_delay = "10s";
        if_id_in = toString netConfig.pdc-tunnel.xfrmId;
        if_id_out = toString netConfig.pdc-tunnel.xfrmId;
        children.default = {
          esp_proposals = [ "aes256gcm16-ecp384" ];
          local_ts = [ "0.0.0.0/0" ] ++ optional (localTunAddrV6 != null) "::/0";
          remote_ts = [ "0.0.0.0/0" ] ++ optional (localTunAddrV6 != null) "::/0";
        };
      };
      includes = [ config.sops.secrets.ipsec-psk.path ];
    };

    services.bird.config =
      let
        bgpV4Cfg = replaceVarsWith {
          src = flakeRoot + /blobs/shitara-overlay/bgp-peer-mopdc-v4.conf;
          replacements = {
            inherit localTunAddrV4 peerTunAddrV4;
          };
        };
        bgpV6Cfg = replaceVarsWith {
          src = flakeRoot + /blobs/shitara-overlay/bgp-peer-mopdc-v6.conf;
          replacements = {
            inherit localTunAddrV6 peerTunAddrV6;
          };
        };
      in
      mkAfter (
        concatLines (
          [ ''include "${bgpV4Cfg.outPath}";'' ]
          ++ optional (localTunAddrV6 != null) ''include "${bgpV6Cfg.outPath}";''
        )
      );

    services.vpn-route-gen.enable = true;

    networking.nftables.tables = {
      global.content = ''
        chain mopdc-input {
          iifname "eth0" udp dport {isakmp, ipsec-nat-t} counter accept
          iifname "xfrm0" ip saddr ${peerTunAddrV4} ip daddr ${localTunAddrV4} tcp dport bgp counter accept
          iifname "xfrm0" ip saddr ${peerTunAddrV4} ip daddr ${localTunAddrV4} udp dport 3784 counter accept
        }
      ''
      + optionalString (localTunAddrV6 != null) ''
        chain mopdc-input {
          iifname "xfrm0" ip6 saddr ${peerTunAddrV6} ip6 daddr ${localTunAddrV6} tcp dport bgp counter accept
          iifname "xfrm0" ip6 saddr ${peerTunAddrV6} ip6 daddr ${localTunAddrV6} udp dport 3784 counter accept
        }
      ''
      + ''
        chain input {
          jump mopdc-input
        }
      '';

      nat.content = ''
        chain source-nat {
          oifname "eth0" ip saddr 10.0.0.0/8 ip daddr ne 10.0.0.0/8 counter masquerade
        }
      '';
    };
  }
)
