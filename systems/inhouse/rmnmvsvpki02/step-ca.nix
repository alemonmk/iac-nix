{
  config,
  lib,
  flakeRoot,
  ...
}:
{
  networking.hosts."127.0.0.1" = [ "atpki.snct.rmntn.net" ];

  environment.etc."smallstep/x509template.tpl".text =
    lib.readFile "${flakeRoot}/blobs/pki/step-ca/x509template.tpl";
  environment.etc."smallstep/root_ca.crt".text = lib.readFile "${flakeRoot}/blobs/pki/root_ca.crt";
  environment.etc."smallstep/intermediate_ca.crt".text =
    lib.readFile "${flakeRoot}/blobs/pki/step-ca/intermediate_ca.crt";
  environment.etc."smallstep/intermediate_ca_key".text =
    lib.readFile "${flakeRoot}/blobs/pki/step-ca/intermediate_ca_key";

  services = {
    step-ca = {
      enable = true;
      settings = lib.importJSON "${flakeRoot}/blobs/pki/step-ca/ca.json";
      intermediatePasswordFile = config.sops.secrets.w1-pkey-password.path;
      address = "127.0.0.1";
      port = 8443;
    };

    caddy = {
      enable = true;
      acmeCA = lib.mkForce "https://atpki.snct.rmntn.net:${toString config.services.step-ca.port}/acme/w1/directory";
      virtualHosts."atpki.snct.rmntn.net".extraConfig = ''
        reverse_proxy https://localhost:${toString config.services.step-ca.port} {
            transport http {
                tls_trust_pool file /etc/smallstep/root_ca.crt
                tls_server_name atpki.snct.rmntn.net
            }
        }
      '';
    };
  };

  systemd.services.step-ca.serviceConfig.StateDirectoryMode = "0700";

  environment.persistence."/nix/persist".directories = [ "/var/lib/private/step-ca" ];
}
