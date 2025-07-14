{
  config,
  pkgs,
  ...
}:
{
  services = {
    code-server = {
      enable = true;
      proxyDomain = "nix-mgr.snct.rmntn.net";
      package = pkgs.vscode-with-extensions.override {
        vscode = pkgs.code-server;
        vscodeExtensions = with pkgs.vscode-extensions; [
          bbenoist.nix
          jeff-hykin.better-nix-syntax
          kamadorueda.alejandra
          davidanson.vscode-markdownlint
          shd101wyy.markdown-preview-enhanced
          signageos.signageos-vscode-sops
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

    caddy.virtualHosts."nix-mgr.snct.rmntn.net".extraConfig =
      "reverse_proxy localhost:${toString config.services.code-server.port}";
  };

  users.users.code-server = {
    home = "/home/code-server";
    createHome = true;
  };
  home-manager.users.code-server = {
    home.stateVersion = "24.11";
    programs.ssh = {
      enable = true;
      matchBlocks = {
        "nix-staging" = {
          host = "10.85.20.61";
          user = "root";
          identityFile = "/run/secrets/nix-remote-sshkey";
          extraOptions = {
            StrictHostKeyChecking = "no";
            UserKnownHostsFile = "/dev/null";
          };
        };
        "public.rmntn.net" = {
          host = "*.shitara.rmntn.net kotone.rmntn.net";
          port = 444;
          user = "root";
          identityFile = "/run/secrets/nix-remote-sshkey";
        };
        "private.rmntn.net" = {
          host = "*";
          user = "root";
          identityFile = "/run/secrets/nix-remote-sshkey";
        };
      };
    };
    programs.bash = {
      enable = true;
      bashrcExtra = ''
        upgrade-system-remote () {
          pushd ~/workspaces/nix > /dev/null
          if [ $1 ]; then
            SHORTHOST=$(cut -d "." -f 1 <<< $1)
            NIX_SSHOPTS="-F $HOME/.ssh/config" nixos-rebuild switch --target-host root@$1 --flake .#$SHORTHOST
          fi
          popd > /dev/null
        }
        install-system-remote () {
          pushd ~/workspaces/nix > /dev/null
          NIX_SSHOPTS="-F $HOME/.ssh/config" nixos-rebuild boot --target-host root@10.85.20.61 --flake .#$1
          ssh root@10.85.20.61 systemctl reboot
          popd > /dev/null
        }
      '';
    };
  };

  environment.persistence."/nix/persist".users.code-server = {
    directories = [ "workspaces" ];
    files = [
      {
        file = ".config/sops/age/keys.txt";
        parentDirectory = {
          mode = "770";
        };
      }
    ];
  };
}
