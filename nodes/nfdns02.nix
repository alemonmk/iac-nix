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
    hostName = "rmnmvnfdns02";
    interfaces.ens192.ipv4.addresses = [
      {
        address = "10.85.10.2";
        prefixLength = 27;
      }
    ];
    defaultGateway = {address = "10.85.10.30";};
    interfaces.ens192.ipv6.addresses = [
      {
        address = "2400:8902:e002:59e0::d:2";
        prefixLength = 64;
      }
    ];
    defaultGateway6 = {address = "2400:8902:e002:59e0::ccef";};
  };

  services = {
    technitium-dns-server = {
      enable = true;
      package = nixpkgs-next.technitium-dns-server;
    };
    caddy = {
      enable = true;
      virtualHosts = {
        "dns02.noc.snct.rmntn.net" = {
          extraConfig = ''
            reverse_proxy localhost:5380 {
                  header_up X-Real-IP {remote_host}
            }
          '';
        };
      };
    };
  };

  environment.persistence."/nix/persist".directories = ["/var/lib/private/technitium-dns-server"];
}
