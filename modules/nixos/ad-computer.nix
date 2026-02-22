{
  config,
  pkgs,
  lib,
  ...
}:
{
  options.users.ms-ad =
    let
      inherit (lib.types)
        bool
        str
        listOf
        attrs
        ;
      inherit (lib.options) mkOption;
    in
    {
      enable = mkOption {
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

      domain = mkOption {
        type = str;
        default = "";
        description = "Active Directory domain to join.";
      };

      sudoers = mkOption {
        type = listOf attrs;
        default = [ ];
        description = "Sudoers rules for the Active Directory domain.";
      };
    };

  config =
    let
      inherit (lib.strings) toUpper toLower;
      AD_D = toUpper config.users.ms-ad.domain;
      ad_d = toLower AD_D;
    in
    lib.modules.mkIf config.users.ms-ad.enable {
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

        realmd.enable = true;
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

      security.polkit.enable = true;

      security.sudo.extraRules = config.users.ms-ad.sudoers;

      environment.systemPackages = with pkgs; [
        adcli
        oddjob
        samba
        realmd
      ];

      environment.persistence."/nix/persist" = {
        directories = [ "/var/lib/sss" ];
        files = [ "/etc/krb5.keytab" ];
      };
    };
}
