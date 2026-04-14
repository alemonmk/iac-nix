{
  config,
  lib,
  nixpkgs-next,
  ...
}:
{
  users.users.dkimsign = {
    group = "dkimsign";
    isSystemUser = true;
  };
  users.groups.dkimsign = { };

  services.opensmtpd = {
    enable = true;
    setSendmail = false;
    package = nixpkgs-next.opensmtpd;
    procPackages = [ nixpkgs-next.opensmtpd-filter-dkimsign ];
    extraServerArgs = [ "-P mda" ];
    serverConfiguration =
      let
        netConfig = import ../base/netconfigs.nix config.networking.hostName;
        dkimSignCmd = lib.strings.concatStringsSep " " [
          "filter-dkimsign"
          "-t"
          "-c relaxed/relaxed"
          "-a rsa-sha256"
          "-d rmntn.net"
          "-s appmsgs"
          "-k ${config.sops.secrets.dkimkey.path}"
        ];
        dkimSignUser = config.users.users.dkimsign.name;
      in
      ''
        table cluster-net { 10.85.183.0/28, 10.91.145.32/28 }
        table outbound-src { ${netConfig.wan.v4} }
        filter dkim-sign proc-exec "${dkimSignCmd}" user ${dkimSignUser} group ${dkimSignUser}
        listen on socket filter "dkim-sign"
        listen on ${netConfig.lo} port 25 filter "dkim-sign"
        action "outbound" relay src <outbound-src>
        match from src <cluster-net> for any action "outbound"
      '';
  };

  networking.nftables.tables.global.content = ''
    chain service-input {
      iifname "ztinv*" ip daddr 10.85.183.6 tcp dport 25 counter accept
    }
  '';
}
