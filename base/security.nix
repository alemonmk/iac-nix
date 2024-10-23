{config, ...}: {
  boot.tmp.cleanOnBoot = true;
  systemd.coredump.enable = false;

  security = {
    pki.certificateFiles = [../blobs/root_ca.crt];
    pki.caCertificateBlacklist = [
      "BJCA Global Root CA1"
      "BJCA Global Root CA2"
      "CFCA EV ROOT"
      "GDCA TrustAUTH R5 ROOT"
      "vTrus ECC Root CA"
      "vTrus Root CA"
      "UCA Extended Validation Root"
      "UCA Global G2 Root"
      "TrustAsia Global Root CA G3"
      "TrustAsia Global Root CA G4"
      "Hongkong Post Root CA 3"
      "TUBITAK Kamu SM SSL Kok Sertifikasi - Surum 1"
      "ACCVRAIZ1"
      "AC RAIZ FNMT-RCM"
      "AC RAIZ FNMT-RCM SERVIDORES SEGUROS"
      "Staat der Nederlanden Root CA - G3"
      "TunTrust Root CA"
    ];
    sudo = {
      enable = true;
      extraConfig = "Defaults lecture = never";
      extraRules = [
        {
          groups = ["sg\\ server\\ administrators@snct.rmntn.net"];
          commands = ["ALL"];
        }
      ];
    };
  };

  users.mutableUsers = false;
  users.users.emergency = {
    isNormalUser = true;
    description = "Emergency local account";
    extraGroups = ["wheel"];
    home = "/home/emergency";
    createHome = true;
    hashedPassword = "$y$j9T$Ddybx4Z6a2Wr9n.DLTvnZ1$OANx4.k6sMJlH.44A7i3jy6q2KBbdYYUfGQttdyaUs9";
  };
  users.ms-ad = {
    enable = true;
    domain = "snct.rmntn.net";
  };

  services = {
    openssh = {
      enable = true;
      settings.KbdInteractiveAuthentication = false;
      extraConfig = ''
        AllowTcpForwarding no
        X11Forwarding no
        AllowAgentForwarding no
        AllowStreamLocalForwarding no
      '';
    };
  };
}
