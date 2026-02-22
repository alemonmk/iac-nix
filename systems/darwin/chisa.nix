{
  pkgs,
  nixpkgs-next,
  flakeRoot,
  lib,
  ...
}:
{
  system.stateVersion = 5;

  nixpkgs.hostPlatform = "x86_64-darwin";
  nix.settings.experimental-features = "nix-command flakes";
  nix.optimise.automatic = true;
  nix.gc.automatic = true;
  nixpkgs.config.allowUnfree = true;

  system.primaryUser = "alemonmk";
  system.defaults = {
    NSGlobalDomain = {
      AppleShowAllExtensions = true;
      NSAutomaticCapitalizationEnabled = false;
      NSAutomaticSpellingCorrectionEnabled = false;
      NSDocumentSaveNewDocumentsToCloud = false;
      "com.apple.trackpad.enableSecondaryClick" = true;
    };
    controlcenter.BatteryShowPercentage = true;
    dock = {
      magnification = true;
      persistent-apps = [
        "/System/Applications/Launchpad.app"
        "/Applications/Safari.app"
        "/System/Applications/System Settings.app"
        "/Applications/Nix Apps/Alacritty.app"
        "/Applications/Bitwarden.app"
        "/Applications/Librewolf.app"
        "/Applications/Visual Studio Code.app"
        "/Applications/Omnissa Horizon Client.app"
        "/Applications/Windows App.app"
        "/Applications/VMware Fusion.app"
      ];
    };
    finder = {
      ShowPathbar = true;
      AppleShowAllExtensions = true;
      FXPreferredViewStyle = "Nlsv";
      FXEnableExtensionChangeWarning = false;
      ShowMountedServersOnDesktop = true;
      _FXSortFoldersFirst = true;
    };
    loginwindow = {
      DisableConsoleAccess = true;
      GuestEnabled = false;
    };
    trackpad = {
      Clicking = true;
      Dragging = true;
      TrackpadRightClick = true;
    };
  };
  networking.applicationFirewall.enable = false;
  system.keyboard = {
    enableKeyMapping = true;
    remapCapsLockToControl = true;
  };
  time.timeZone = "Asia/Taipei";

  security.pki = {
    certificateFiles = [ "${flakeRoot}/blobs/pki/root_ca.crt" ];
    caCertificateBlacklist = [
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
  };

  networking = {
    computerName = "chisa";
    hostName = "chisa";
  };

  environment.systemPackages =
    (with pkgs; [
      coreutils
      alacritty
      screen
      iproute2mac
      curl
      jq
      git
      eza
      fd
      python314
      terraform
      consul
      nomad
      nixfmt-rfc-style
      sops
      age
      ruff
      nmap
      unar
      uv
    ])
    ++ (with nixpkgs-next; [
      nushell
    ]);
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      cleanup = "zap";
      upgrade = true;
    };
    casks =
      lib.map
        (x: {
          name = x;
          greedy = true;
        })
        [
          "adobe-acrobat-reader"
          "araxis-merge"
          "drawio"
          "librewolf"
          "visual-studio-code"
          "sqlitestudio"
          "coconutbattery"
          "keyboardcleantool"
          "linearmouse"
          "openinterminal-lite"
          "wireshark-app"
          "vmware-fusion"
          "zerotier-one"
          "yubico-authenticator"
          "omnissa-horizon-client"
          "windows-app"
          "anydesk"
          "wechat"
          "whatsapp"
          "microsoft-teams"
          "voov-meeting"
          "webex"
          "zoom"
          "font-input"
        ];
    masApps = {
      "Brother P-touch Editor" = 1453365242;
      "Bitwarden" = 1352778147;
      "ICMPUtil" = 866965011;
    };
  };
  environment.shells = [
    pkgs.bashInteractive
    pkgs.zsh
    nixpkgs-next.nushell
  ];

  imports = [
    "${flakeRoot}/home/chisa"
  ];
}
