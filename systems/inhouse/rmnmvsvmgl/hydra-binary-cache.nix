{
  config,
  lib,
  pkgs,
  ...
}:
{
  fileSystems."/nix/bcache" = {
    device = "/dev/disk/by-partlabel/BCACHE";
    fsType = "ext4";
    options = [ "noatime" ];
    autoResize = true;
  };

  nix = {
    settings.gc-keep-outputs = lib.mkForce false;
    extraOptions = "allowed-uris = https://github.com/ https://code.rmntn.net github:";
  };

  services = {
    journald.rateLimitBurst = 0;

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

    caddy.virtualHosts."nix-ci.snct.rmntn.net".extraConfig =
      "reverse_proxy localhost:${toString config.services.hydra.port}";
    caddy.virtualHosts."nix-cache.snct.rmntn.net".extraConfig = ''
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
  };

  systemd.services.nix-daemon.environment.TMPDIR = "/nix/persist/buildtmp";
  systemd.services.hydra-evaluator.environment.GC_DONT_GC = "true";
  systemd.services.hydra-notify.enable = false;
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

  environment.persistence."/nix/persist".directories = [
    "/var/lib/hydra"
    "/var/lib/postgresql"
  ];
}
