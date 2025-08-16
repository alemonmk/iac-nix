{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (config.networking) hostName;
  netConfig = import ./netconfigs.nix { inherit hostName; };
  wanAddress = netConfig.wan.v4;
  localTunAddrV4 = netConfig.pdc-tunnel.local.v4;
  localTunAddrV6 = lib.optionalString (netConfig.pdc-tunnel.local ? v6) netConfig.pdc-tunnel.local.v6;
  peerTunAddrV4 = netConfig.pdc-tunnel.peer.v4;
  peerTunAddrV6 = lib.optionalString (netConfig.pdc-tunnel.peer ? v6) netConfig.pdc-tunnel.peer.v6;
in
{
  systemd.network = {
    config.networkConfig.IPv6Forwarding = localTunAddrV6 != "";
    networks."2-eth0".xfrm = [ "xfrm0" ];
    networks."10-xfrm0" = {
      matchConfig.Name = "xfrm0";
      linkConfig.MTUBytes = 1400;
      address = [ "${localTunAddrV4}/31" ] ++ lib.optional (localTunAddrV6 != "") "${localTunAddrV6}/64";
    };
    netdevs."10-xfrm0" = {
      netdevConfig = {
        Name = "xfrm0";
        Kind = "xfrm";
      };
      xfrmConfig.InterfaceId = netConfig.pdc-tunnel.xfrmId;
    };
  };

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
      if_id_in = builtins.toString netConfig.pdc-tunnel.xfrmId;
      if_id_out = builtins.toString netConfig.pdc-tunnel.xfrmId;
      children.default = {
        esp_proposals = [ "aes256gcm16-ecp384" ];
        local_ts = [ "0.0.0.0/0" ] ++ lib.optional (localTunAddrV6 != "") "::/0";
        remote_ts = [ "0.0.0.0/0" ] ++ lib.optional (localTunAddrV6 != "") "::/0";
      };
    };
    includes = [ config.sops.secrets.ipsec-psk.path ];
  };

  services.bird.config =
    let
      bgpV4Cfg = pkgs.replaceVarsWith {
        src = ../../blobs/shitara-overlay/bgp-peer-mopdc-v4.conf;
        replacements = {
          inherit localTunAddrV4 peerTunAddrV4;
        };
      };
      bgpV6Cfg = pkgs.replaceVarsWith {
        src = ../../blobs/shitara-overlay/bgp-peer-mopdc-v6.conf;
        replacements = {
          inherit localTunAddrV6 peerTunAddrV6;
        };
      };
    in
    lib.mkAfter (
      lib.concatLines (
        [ ''include "${bgpV4Cfg.outPath}";'' ]
        ++ lib.optional (localTunAddrV6 != "") ''include "${bgpV6Cfg.outPath}";''
      )
    );

  services.vpn-route-gen.enable = true;

  networking.nftables.tables = {
    global.content = ''
      chain mopdc-input {
        iifname "eth0" udp dport {isakmp, ipsec-nat-t} counter accept
        iifname "xfrm0" ip saddr 10.91.145.0/26 ip daddr ${localTunAddrV4} tcp dport bgp counter accept
      }
    ''
    + lib.optionalString (localTunAddrV6 != "") ''
      chain mopdc-input {
        iifname "xfrm0" ip6 saddr ${peerTunAddrV6} ip6 daddr ${localTunAddrV6} tcp dport bgp counter accept
      }
    ''
    + ''
      chain input {
        jump mopdc-input
      }
    '';

    nat = {
      family = "ip";
      content = ''
        chain postrouting {
          type nat hook postrouting priority srcnat; policy accept
          oifname "eth0" ip saddr 10.0.0.0/8 ip daddr ne 10.0.0.0/8 counter masquerade
        }
      '';
    };
  };
}
