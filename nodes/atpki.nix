{
  config,
  lib,
  nixpkgs-next,
  ...
}: {
  sops = {
    age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
    secrets.w1-pkey-password = {
      mode = "0440";
      owner = config.users.users.step-ca.name;
      group = config.users.users.step-ca.group;
      sopsFile = ../secrets/atpki/ca-w1.yaml;
    };
  };

  networking = {
    hostName = "rmnmvatpki";
    hosts."127.0.0.1" = ["atpki.snct.rmntn.net"];
  };

  systemd.network.networks."1-ens192" = {
    matchConfig.Name = "ens192";
    address = [
      "10.85.101.17/28"
      "2400:8902:e002:59ee::5701:ce01/64"
    ];
    gateway = [
      "10.85.101.30"
      "2400:8902:e002:59ee::ccef"
    ];
    networkConfig.LLDP = false;
  };

  environment.etc."smallstep/x509template.tpl".text = lib.readFile ../blobs/pki/step-ca/x509template.tpl;
  environment.etc."smallstep/root_ca.crt".text = lib.readFile ../blobs/pki/root_ca.crt;
  environment.etc."smallstep/intermediate_ca.crt".text = lib.readFile ../blobs/pki/step-ca/intermediate_ca.crt;
  environment.etc."smallstep/intermediate_ca_key".text = lib.readFile ../blobs/pki/step-ca/intermediate_ca_key;

  services = {
    step-ca = {
      enable = true;
      settings = lib.importJSON ../blobs/pki/step-ca/ca.json;
      intermediatePasswordFile = config.sops.secrets.w1-pkey-password.path;
      address = "127.0.0.1";
      port = 8443;
    };
    caddy = {
      enable = true;
      package = nixpkgs-next.caddy;
      acmeCA = lib.mkForce "https://atpki.snct.rmntn.net:8443/acme/w1/directory";
      virtualHosts = {
        "atpki.snct.rmntn.net" = {
          extraConfig = ''
            reverse_proxy https://localhost:8443 {
                transport http {
                    tls_trust_pool file /etc/smallstep/root_ca.crt
                    tls_server_name atpki.snct.rmntn.net
                }
            }
          '';
        };
      };
    };
  };

  environment.persistence."/nix/persist" = {
    directories = [
      "/var/lib/private/step-ca"
    ];
  };
}
