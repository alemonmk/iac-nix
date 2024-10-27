{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ../base/configuration.nix
  ];

  networking = {
    hostName = "rmnmvatpki";
    interfaces.ens192.ipv4.addresses = [
      {
        address = "10.85.101.17";
        prefixLength = 28;
      }
    ];
    defaultGateway = {address = "10.85.101.30";};
    interfaces.ens192.ipv6.addresses = [
      {
        address = "2400:8902:e002:59ee::5701:ce01";
        prefixLength = 64;
      }
    ];
    defaultGateway6 = {address = "2400:8902:e002:59ee::ccef";};
  };

  environment.systemPackages = with pkgs; [];

  environment.etc."smallstep/x509template.tpl".text = builtins.readFile ../blobs/pki/step-ca/x509template.tpl;
  environment.etc."smallstep/root_ca.crt".text = builtins.readFile ../blobs/pki/root_ca.crt;
  environment.etc."smallstep/intermediate_ca.crt".text = builtins.readFile ../blobs/pki/step-ca/intermediate_ca.crt;
  environment.etc."smallstep/intermediate_ca_key" = {
    text = builtins.readFile ../blobs/pki/step-ca/intermediate_ca_key;
    mode = "0600";
  };

  services = {
    step-ca = {
      enable = true;
      settings = builtins.fromJSON (builtins.readFile ../blobs/pki/step-ca/ca.json);
      # intermediatePasswordFile = config.sops.secrets.ca.w1.private-key.path;
      address = "127.0.0.1";
      port = 8443;
    };
    caddy = {
      enable = true;
      acmeCA = lib.mkForce "http://127.0.0.1:8443/acme/w1/directory";
      virtualHosts = {
        "atpki.snct.rmntn.net" = {
          extraConfig = ''
            reverse_proxy https://localhost:8443 {
                header_up X-Real-IP {remote_host}
                    transport http {
                        tls_trust_pool file {
                            pem_file /etc/smallstep/root_ca.crt
                        }
                    }
                }
            }
          '';
        };
      };
    };
  };

  environment.persistence."/nix/persist" = {
    directories = [
      "/var/lib/step-ca"
    ];
  };
}
