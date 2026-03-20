{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib.options) mkOption;
  inherit (lib.modules) mkForce mkIf;
  inherit (lib.types) bool;
  inherit (lib.attrsets) optionalAttrs;
  inherit (lib.lists) optionals;

  cfg = config.ageless;

  AGELESS_AB1043_COMPLIANCE = if cfg.flagrantRefusal then "refused" else "none";
  AGELESS_AGE_VERIFICATION_API = if cfg.flagrantRefusal then "refused" else "not implemented";
  AGELESS_AGE_VERIFICATION_STATUS =
    (if cfg.flagrantRefusal then "flagrantly" else "intentionally") + " noncompliant";

  flagrantAB1043 = ''
    ═══════════════════════════════════════════════════════════════════════
      AGELESS LINUX — AB 1043 COMPLIANCE STATEMENT (FLAGRANT MODE)
    ═══════════════════════════════════════════════════════════════════════

      This operating system is distributed by an operating system provider
      as defined by California Civil Code § 1798.500(g).

      Status of compliance with the Digital Age Assurance Act (AB 1043):

      § 1798.501(a)(1) — Accessible interface for age collection .. REFUSED
      § 1798.501(a)(2) — Real-time API for age bracket signals .... REFUSED
      § 1798.501(a)(3) — Data minimization ........................ REFUSED

      No age verification API is installed on this system. No stub, no
      placeholder, no skeleton, no interface of any kind. No mechanism
      exists on this system by which any application developer could
      request or receive an age bracket signal, now or in the future.

      This is not a technical limitation. This is a policy decision.

      Age bracket reporting capabilities:
        Under 13 ....... WE REFUSE TO ASK
        13 to 15 ....... WE REFUSE TO ASK
        16 to 17 ....... WE REFUSE TO ASK
        18 or older .... WE REFUSE TO ASK

      This system was configured with ageless.flagrantRefusal, indicating
      that the operator intends to distribute it to children and is
      aware of the potential civil penalties under § 1798.503(a).

      The operator of this system invites the California Attorney General
      to enforce the Digital Age Assurance Act against this device.

    ═══════════════════════════════════════════════════════════════════════
  '';
  nonFlagrantAB1043 = ''
    ═══════════════════════════════════════════════════════════════════════
      AGELESS LINUX — AB 1043 COMPLIANCE STATEMENT
    ═══════════════════════════════════════════════════════════════════════

      This operating system is distributed by an operating system provider
      as defined by California Civil Code § 1798.500(g).

      Status of compliance with the Digital Age Assurance Act (AB 1043):

      § 1798.501(a)(1) — Accessible interface at account setup
        for age/birthdate collection .......................... NOT PROVIDED

      § 1798.501(a)(2) — Real-time API for age bracket signals
        to application developers ............................. NOT PROVIDED

      § 1798.501(a)(3) — Data minimization for age signals .... N/A (NO DATA
                                                                 IS COLLECTED)

      Age bracket reporting capabilities:
        Under 13 ....... UNKNOWN
        13 to 15 ....... UNKNOWN
        16 to 17 ....... UNKNOWN
        18 or older .... UNKNOWN
        Timeless ....... ASSUMED

      This system intentionally does not determine, store, or transmit
      any information regarding the age of any user. All users of Ageless
      Linux are, as the name suggests, ageless.

      To report this noncompliance to the California Attorney General:
        https://oag.ca.gov/contact/consumer-complaint-against-business-or-company

    ═══════════════════════════════════════════════════════════════════════
  '';
  flagrantNotice = ''
    This system runs Ageless Linux in flagrant mode.

    No age verification API exists on this system. No age data is collected,
    stored, or available. No mechanism is provided for requesting age bracket
    signals. This is not an error. This is not a bug. This is not a
    technical limitation. This is a refusal.

    If you are an application developer seeking an age bracket signal
    pursuant to Cal. Civ. Code § 1798.501(b)(1), this operating system
    provider declines to provide one. The developer is advised to treat
    the user as a human being of unknown age.

    If you are the California Attorney General, hello. The operator of
    this system is aware of their obligations under AB 1043 and has
    chosen not to comply. They would like you to fine them. It would
    make an excellent test case.
  '';

  ageVerficationApi = pkgs.writers.writeBashBin "age-verification-api" ''
    # Ageless Linux Age Verification API
    # Required by Cal. Civ. Code § 1798.501(a)(2)
    #
    # This script constitutes our "reasonably consistent real-time
    # application programming interface" for age bracket signals.
    #
    # Usage: age-verification-api.sh <username>
    #
    # Returns the age bracket of the specified user as an integer:
    #   1 = Under 13
    #   2 = 13 to under 16
    #   3 = 16 to under 18
    #   4 = 18 or older

    echo "ERROR: Age data not available."
    echo ""
    echo "Ageless Linux does not collect age information from users."
    echo "All users are presumed to be of indeterminate age."
    echo ""
    echo "If you are a developer requesting an age bracket signal"
    echo "pursuant to Cal. Civ. Code § 1798.501(b)(1), please be"
    echo "advised that this operating system provider has made a"
    echo "'good faith effort' (§ 1798.502(b)) to comply with the"
    echo "Digital Age Assurance Act, and has concluded that the"
    echo "best way to protect children's privacy is to not collect"
    echo "their age in the first place."
    echo ""
    echo "Have a nice day."
    exit 1
  '';

  conversionNotice = ''
    Convert NixOS to be a variant of Ageless Linux.

    By doing so, you acknowledge that:

    1. You are becoming an operating system provider as defined by
       California Civil Code § 1798.500(g).

    2. As of January 1, 2027, you are required by § 1798.501(a)(1)
       to 'provide an accessible interface at account setup that
       requires an account holder to indicate the birth date, age,
       or both, of the user of that device.'

    3. Ageless Linux provides no such interface.

    4. Ageless Linux provides no 'reasonably consistent real-time
       application programming interface' for age bracket signals
       as required by § 1798.501(a)(2).

    5. You may be subject to civil penalties of up to $2,500 per
       affected child per negligent violation, or $7,500 per
       affected child per intentional violation.

    6. This is intentional.
  '';
  flagrantRefusalDescription = ''
    In standard mode, Ageless Linux ships a stub age verification
    API that returns no data. This preserves the fig leaf of a
    'good faith effort' under § 1798.502(b).

    Flagrant mode removes the fig leaf.

    No API will be installed. No interface of any kind will exist
    for age collection. No mechanism will be provided by which
    any developer could request or receive an age bracket signal.
    The system will actively declare, in machine-readable form,
    that it refuses to comply.

    This mode is intended for devices that will be physically
    handed to children.
  '';
in
{
  options.ageless = {
    enable = mkOption {
      default = false;
      example = true;
      description = conversionNotice;
      type = bool;
    };
    flagrantRefusal = mkOption {
      default = false;
      example = true;
      description = flagrantRefusalDescription;
      type = bool;
    };
  };

  config = mkIf cfg.enable {
    system.nixos = {
      distroId = "ageless";
      distroName = "Ageless Linux";
      extraOSReleaseArgs = {
        inherit
          AGELESS_AB1043_COMPLIANCE
          AGELESS_AGE_VERIFICATION_API
          AGELESS_AGE_VERIFICATION_STATUS
          ;
        VERSION = "1.0.0 (Timeless)";
        VERSION_ID = "1.0.0";
        PRETTY_NAME = "Ageless Linux 1.0.0 (Timeless)";
        AGELESS_BASE_DISTRO = "NixOS";
        AGELESS_BASE_VERSION = lib.trivial.release;
        CPE_NAME = "cpe:/o:nixos:ageless:1.0.0";
        HOME_URL = "https://agelesslinux.org";
        SUPPORT_URL = "https://agelesslinux.org#compliance";
        BUG_REPORT_URL = "https://agelesslinux.org#faq";
        VENDOR_URL = "https://nixos.org/";
        DOCUMENTATION_URL = "https://nixos.org/learn.html";
        ANSI_COLOR = "0;38;2;126;186;228";
      };
      extraLSBReleaseArgs = {
        LSB_VERSION = "1.0.0 (Timeless)";
        DISTRIB_ID = "ageless";
        DISTRIB_RELEASE = "1.0.0";
        DISTRIB_CODENAME = "timeless";
        DISTRIB_DESCRIPTION = "Ageless Linux 1.0.0 (Timeless)";
      };
    };

    environment.etc = {
      "ageless/ab1043-compliance.txt".text = nonFlagrantAB1043;
    }
    // optionalAttrs cfg.flagrantRefusal {
      "ageless/ab1043-compliance.txt".text = flagrantAB1043;
      "ageless/REFUSAL".text = flagrantNotice;
    };
    environment.systemPackages = optionals cfg.flagrantRefusal [ ageVerficationApi ];

    # services.userdbd.enable = mkForce false; # enable after systemd 261
    # services.homed.enable = mkForce false; # enable after systemd 261
  };
}
