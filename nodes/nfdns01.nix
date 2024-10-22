{
  config,
  lib,
  pkgs,
  nixpkgs-unstable,
  ...
}: {
  imports = [
    ../base/configuration.nix
  ];

  networking = {
    hostName = "rmnmvnfdns01";
    interfaces.ens192.ipv4.addresses = [
      {
        address = "10.85.10.1";
        prefixLength = 27;
      }
    ];
    defaultGateway = {address = "10.85.10.30";};
    interfaces.ens192.ipv6.addresses = [
      {
        address = "2400:8902:e002:59e0::d:1";
        prefixLength = 64;
      }
    ];
    defaultGateway6 = {address = "2400:8902:e002:59e0::ccef";};
  };

  environment.systemPackages = [
    nixpkgs-unstable.technitium-dns-server
  ];

  services = {
    technitium-dns-server.enable = true;
    caddy = {
      enable = true;
      virtualHosts = {
        "dns01.noc.snct.rmntn.net" = {
          extraConfig = ''
            reverse_proxy localhost:5380 {
                  header_up X-Real-IP {remote_host}
            }
          '';
        };
      };
    };
  };

  environment.persistence."/nix/persist" = {
    directories = [
      "/var/lib/technitium-dns-server"
    ];
  };
}
