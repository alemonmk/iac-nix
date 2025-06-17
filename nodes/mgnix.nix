{
  config,
  lib,
  pkgs,
  ...
}: {
  sops = {
    age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
    secrets.nix-remote-sshkey = {
      mode = "0400";
      owner = config.users.users.code-server.name;
      group = config.users.users.code-server.group;
      sopsFile = ../secrets/mgnix/remote-sshkey.yaml;
    };
    secrets.ci-signing-key = {
      mode = "0440";
      group = config.users.users.hydra.group;
      sopsFile = ../secrets/mgnix/ci-signing-key.yaml;
    };
  };

  networking.hostName = "rmnmvmgnix";

  fileSystems."/nix/bcache" = {
    device = "/dev/disk/by-partlabel/BCACHE";
    fsType = "ext4";
    options = ["noatime"];
    autoResize = true;
  };

  systemd.network.networks."1-ens192" = {
    matchConfig.Name = "ens192";
    address = [
      "10.85.20.11/26"
      "2400:8902:e002:59e3::c:4d79/64"
    ];
    gateway = [
      "10.85.20.62"
      "2400:8902:e002:59e3::ccef"
    ];
    networkConfig.LLDP = false;
  };

  environment.systemPackages = with pkgs; [
    alejandra
    sops
  ];

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
          host = "*.shitara.rmntn.net";
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

  nix = {
    settings.gc-keep-outputs = lib.mkForce false;
    extraOptions = ''
      allowed-uris = https://github.com/ https://code.rmntn.net github:
    '';
  };

  services = {
    journald.rateLimitBurst = 0;

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

    hydra = {
      enable = true;
      hydraURL = "https://nix-ci.snct.rmntn.net";
      listenHost = "localhost";
      port = 4445;
      useSubstitutes = true;
      notificationSender = "nix-ci@snct.rmntn.net";
      extraConfig = ''
        store_uri = file:///nix/bcache?write-nar-listing=true&secret-key=${config.sops.secrets.ci-signing-key.path}&compression=zstd&parallel-compression=true
        binary_cache_public_uri = https://nix-cache.snct.rmntn.net
        log_prefix = https://nix-cache.snct.rmntn.net/
        upload_logs_to_binary_cache = true
        compress_build_logs = 0
        allow_import_from_derivation = false
      '';
      extraEnv = {
        http_proxy = "http://10.85.20.10:3128";
        https_proxy = "http://10.85.20.10:3128";
      };
    };

    caddy = {
      enable = true;
      virtualHosts = {
        "nix-mgr.snct.rmntn.net".extraConfig = "reverse_proxy localhost:${toString config.services.code-server.port}";
        "nix-cache.snct.rmntn.net".extraConfig = ''
          import cors https://nix-ci.snct.rmntn.net
          uri query -*
          handle /nix-cache-info {
            header Content-Type text/x-nix-cache-info
              respond 200 {
              body <<TXT
              StoreDir: /nix/store
              WantMassQuery: 1
              Priority: 30
              TXT
              close
            }
          }
          respond / "nix-cache.snct.rmntn.net is up" 200
          header /*.narinfo Content-Type text/x-nix-narinfo
          header /nar/* Content-Type application/x-nix-nar
          header /log/* Content-Type "text/plain; charset=utf8"
          file_server {
            root /nix/bcache
          }
        '';
        "nix-ci.snct.rmntn.net".extraConfig = "reverse_proxy localhost:${toString config.services.hydra.port}";
      };
    };
  };

  systemd.services.nix-daemon.environment.TMPDIR = "/nix/persist/buildtmp";
  systemd.services.hydra-evaluator.environment.GC_DONT_GC = "true";
  systemd.services.hydra-prune-build-logs = {
    description = "Clean up old build logs";
    startAt = "weekly";
    serviceConfig = {
      User = "hydra-queue-runner";
      Group = "hydra";
      ExecStart = lib.concatStringsSep " " [
        (lib.getExe pkgs.findutils)
        "/var/lib/hydra/build-logs/"
        "-ignore_readdir_race"
        "-type"
        "f"
        "-mtime"
        "+90"
        "-delete"
      ];
    };
  };

  environment.persistence."/nix/persist" = {
    directories = [
      "/var/lib/hydra"
      "/var/lib/postgresql"
    ];
    users.code-server = {
      directories = ["workspaces"];
      files = [".config/sops/age/keys.txt"];
    };
  };
}
