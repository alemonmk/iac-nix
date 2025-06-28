let
  netConfigs = [
    {
      host = "sumire";
      lo = "10.85.183.1";
      pdc-tunnel = {
        local.v4 = "10.91.145.19";
        peer.v4 = "10.91.145.18";
        localId = "@jp1-n2.glb-tnsp.snct.rmntn.net";
        xfrmId = 2383257886;
      };
      wan.v4 = "139.162.106.232";
      wan.v6 = "2400:8902::2000:56ff:fee7:7c84";
    }
    {
      host = "uzuki";
      lo = "10.85.183.2";
      pdc-tunnel = {
        local.v4 = "10.91.145.21";
        peer.v4 = "10.91.145.20";
        localId = "@jp1-n3.glb-tnsp.snct.rmntn.net";
        xfrmId = 2786241757;
      };
      wan.v4 = "172.235.214.168";
      wan.v6 = "2400:8905::2000:36ff:fe6f:80ba";
    }
    {
      host = "sajuna";
      lo = "10.85.183.3";
      wan.v4 = "139.162.81.228";
      wan.v6 = "2400:8902::2000:f1ff:fee3:e4d4";
    }
    {
      host = "kumiko";
      lo = "10.85.183.4";
      wan.v4 = "172.237.30.98";
      wan.v6 = "2600:3c18::2000:3eff:fe4b:3ae9";
    }
    {
      host = "sena";
      lo = "10.85.183.5";
      wan.v4 = "172.235.214.169";
      wan.v6 = "2400:8905::2000:19ff:fe76:e92d";
    }
    {
      host = "kotone";
      lo = "10.85.183.6";
      pdc-tunnel = {
        local.v4 = "10.91.145.17";
        local.v6 = "2400:8902:e002:59a1::aec1";
        peer.v4 = "10.91.145.16";
        peer.v6 = "2400:8902:e002:59a1::aec2";
        localId = "@jp1-n1.glb-tnsp.snct.rmntn.net";
        xfrmId = 2851101766;
      };
      wan.v4 = "139.162.122.174";
      wan.v6 = "2400:8902::f03c:91ff:fe70:9cad";
    }
  ];
  inherit (builtins) head filter;
in
{ hostName }:
head (filter (e: e.host == hostName) netConfigs)
