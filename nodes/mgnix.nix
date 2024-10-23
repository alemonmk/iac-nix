{
  config,
  lib,
  pkgs,
  nixpkgs-unstable,
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

  environment.systemPackages = with pkgs; [code-server];

  users.users.code-server = {
    home = "/home/code-server";
    createHome = true;
  };

  services = {
    code-server = {
      enable = true;
      proxyDomain = "nix-mgr.snct.rmntn.net";
      package = nixpkgs-unstable.vscode-with-extensions.override {
        vscode = nixpkgs-unstable.code-server;
        vscodeExtensions = with nixpkgs-unstable.vscode-extensions; [
          bbenoist.nix
          jeff-hykin.better-nix-syntax
          davidanson.vscode-markdownlint
          shd101wyy.markdown-preview-enhanced
          uloco.theme-bluloco-light
        ];
      };
      userDataDir = "/home/code-server/workspaces";
      extensionsDir = "/home/code-server/code-ext";
      disableWorkspaceTrust = true;
      disableUpdateCheck = true;
      disableTelemetry = true;
      disableGettingStartedOverride = true;
      hashedPassword = "$argon2id$v=19$m=4096,t=3,p=1$dXQwcTJ2MzVuOTgyZg$/Vp0CjZ4wiFe2F7l5bQRb07XFHyobAtCuOrHDQqxkY0";
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
      directories = ["workspaces/nix" "code-ext"];
    };
  };
}
