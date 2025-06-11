{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.users.ms-ad;
in {
  options = {
    users.ms-ad = with lib.types; {
      enable = lib.mkOption {
        type = bool;
        default = false;
        description = ''
          Join the specified Active Directory domain.
          Run the following command after nixos-rebuild switch to actually join the domain:
          ```
          sudo adcli join \
            -D <domain> \
            -U <user>@<CAPTALIZED DOMAIN> \
            -O "<Full DN to desired OU>"
          ```
        '';
      };

      domain = lib.mkOption {
        type = str;
        default = "";
        description = "Active Directory domain to join.";
      };

      sudoers = lib.mkOption {
        type = listOf attrs;
        default = [];
        description = "Sudoers rules for the Active Directory domain";
      };
    };
  };

  config = lib.mkIf cfg.enable (
    let
      AD_D = lib.toUpper cfg.domain;
      ad_d = lib.toLower cfg.domain;
    in {
      services = {
        sssd = {
          enable = true;
          config = ''
            [sssd]
            domains = ${ad_d}
            config_file_version = 2
            services = nss, pam

            [domain/${ad_d}]
            ad_domain = ${ad_d}
            krb5_realm = ${AD_D}
            realmd_tags = manages-system joined-with-adcli
            cache_credentials = True
            id_provider = ad
            krb5_store_password_if_offline = True
            default_shell = ${pkgs.bashInteractive}/bin/bash
            ldap_id_mapping = True
            use_fully_qualified_names = True
            access_provider = simple
            override_homedir = /home/%d/%u
            ad_gpo_access_control = enforcing
            dyndns_update = True
            simple_allow_groups = SG Server Administrators
          '';
        };
      };

      security.pam.services.sshd.makeHomeDir = true;

      security.krb5 = {
        enable = true;
        settings = {
          libdefaults = {
            udp_preference_limit = 0;
            default_realm = AD_D;
          };
        };
      };

      systemd.services.realmd = {
        description = "Realm Discovery Service";
        wantedBy = ["multi-user.target"];
        after = ["network.target"];
        serviceConfig = {
          Type = "dbus";
          BusName = "org.freedesktop.realmd";
          ExecStart = "${pkgs.realmd}/libexec/realmd";
          User = "root";
        };
      };

      security.sudo.extraRules = cfg.sudoers;

      environment.systemPackages = with pkgs; [
        adcli
        oddjob
        samba
        realmd
      ];

      environment.persistence."/nix/persist" = {
        directories = ["/var/lib/sss"];
        files = ["/etc/krb5.keytab"];
      };
    }
  );
}
