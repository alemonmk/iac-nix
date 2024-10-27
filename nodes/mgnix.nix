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
    hostName = "rmnmvmgnix";
    interfaces.ens192.ipv4.addresses = [
      {
        address = "10.85.20.11";
        prefixLength = 26;
      }
    ];
    defaultGateway = {address = "10.85.20.62";};
    interfaces.ens192.ipv6.addresses = [
      {
        address = "2400:8902:e002:59e3::c:4d79";
        prefixLength = 64;
      }
    ];
    defaultGateway6 = {address = "2400:8902:e002:59e3::ccef";};
  };

  environment.systemPackages = with pkgs; [alejandra];

  users.users.code-server = {
    home = "/home/code-server";
    createHome = true;
  };

  services = {
    code-server = {
      enable = true;
      proxyDomain = "nix-mgr.snct.rmntn.net";
      package = nixpkgs-next.vscode-with-extensions.override {
        vscode = nixpkgs-next.code-server;
        vscodeExtensions = with nixpkgs-next.vscode-extensions; [
          bbenoist.nix
          jeff-hykin.better-nix-syntax
          kamadorueda.alejandra
          davidanson.vscode-markdownlint
          shd101wyy.markdown-preview-enhanced
          uloco.theme-bluloco-light
        ];
      };
      userDataDir = "/home/code-server/workspaces";
      disableWorkspaceTrust = true;
      disableUpdateCheck = true;
      disableTelemetry = true;
      disableGettingStartedOverride = true;
      hashedPassword = "$argon2i$v=19$m=4096,t=3,p=1$NHJ2MGczNzR1MXE4OTB5dXJ3d2Vpb3I$9SJioCgKkNW4yaSpe8vtipgdyFHpnASrqKsdcpQ8ygM";
    };

    caddy = {
      enable = true;
      virtualHosts = {
        "nix-mgr.snct.rmntn.net" = {
          extraConfig = ''
            reverse_proxy localhost:4444 {
                    header_up X-Real-IP {remote_host}
            }
          '';
        };
      };
    };
  };

  environment.persistence."/nix/persist" = {
    users.code-server = {
      directories = ["workspaces"];
      files = [".config/sops/age/keys.txt"];
    };
  };
}
