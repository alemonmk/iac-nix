{
  config,
  lib,
  pkgs,
  nixpkgs-next,
  ...
}: {
  imports = [
    ../base/configuration.nix
  ];

  networking = {
    hostName = "rmnmvwebgw";
    interfaces.ens192.ipv4.addresses = [
      {
        address = "10.85.20.10";
        prefixLength = 26;
      }
    ];
    defaultGateway = {address = "10.85.20.62";};
    interfaces.ens192.ipv6.addresses = [
      {
        address = "2400:8902:e002:59e3::403:9ae7";
        prefixLength = 64;
      }
    ];
    defaultGateway6 = {address = "2400:8902:e002:59e3::ccef";};
  };

  environment.etc."squid/acl/entra-id".text = builtins.readFile ../blobs/squid/acl/entra-id;
  environment.etc."squid/acl/exchange-online".text = builtins.readFile ../blobs/squid/acl/exchange-online;
  environment.etc."squid/acl/wsus".text = builtins.readFile ../blobs/squid/acl/wsus;

  services = {
    squid = {
        enable = true;
        package = nixpkgs-next.squid;
        configText = builtins.readFile ../blobs/squid/config;
    };
  };
}
