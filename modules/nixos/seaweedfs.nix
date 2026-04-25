{
  self,
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.seaweedfs;
in
{
  options.services.seaweedfs =
    let
      inherit (lib.types)
        nullOr
        listOf
        str
        port
        ints
        enum
        ;
      inherit (lib.options)
        mkOption
        mkEnableOption
        mkPackageOption
        literalExpression
        ;
    in
    {
      rootDir = mkOption {
        description = ''
          Directory containing all persistent data.
          Directories for master, volume, filer, admin UI server will be automatically created under this directory.
        '';
        type = str;
      };
      package = mkPackageOption pkgs "seaweedfs" { };
      user = mkOption {
        description = "The user under which `seaweedfs` runs.";
        default = "seaweedfs";
        type = str;
      };
      dataCenter = mkOption {
        description = ''
          The identifier of volume server's data center.
          Also sets preferred data center of S3 gateway.
        '';
        default = "DefaultDataCenter";
        type = str;
      };
      rack = mkOption {
        description = "The identifier of volume server's rack.";
        default = "none";
        type = str;
      };
      listenAddr = mkOption {
        description = "Address that master, volume, filer, S3 gateway services should listen on.";
        default = "localhost";
        type = str;
      };
      masters = mkOption {
        description = "Master servers to join. Must set when master server is not run locally.";
        default = [ ];
        example = literalExpression ''
          [
            "192.168.0.1:9333"
            "192.168.0.2:9399"
          ]
        '';
        type = listOf str;
      };
      securityFile = mkOption {
        description = ''
          File containing security configurations for master, volume and filer server.
          A sample file can be generated with `nix run nixpkgs#seaweedfs -- scaffold -config=security`.
          See [Security Overview](https://github.com/seaweedfs/seaweedfs/wiki/Security-Overview) and [Security Configuration](https://github.com/seaweedfs/seaweedfs/wiki/Security-Configuration).
        '';
        default = null;
        type = nullOr str;
      };
      master = {
        enable = mkEnableOption "SeaweedFS master server";
        port = mkOption {
          description = "HTTP listen port.";
          default = 9333;
          type = port;
        };
        grpcPort = mkOption {
          description = "GRPC listen port.";
          default = cfg.master.port + 10000;
          type = port;
        };
        peers = mkOption {
          description = "List all master nodes. Leave empty if running standalone.";
          default = [ ];
          example = literalExpression ''
            [
              "192.168.0.1:9333"
              "192.168.0.2:9399"
            ]
          '';
          type = listOf str;
        };
        extraArgs = mkOption {
          description = "Extra arguments to be passed to `weed master`.";
          default = [ ];
          type = listOf str;
        };
      };
      volume = {
        enable = mkEnableOption "SeaweedFS volume server";
        useRustServer = mkEnableOption "Rust volume server";
        port = mkOption {
          description = "HTTP listen port.";
          default = 8080;
          type = port;
        };
        grpcPort = mkOption {
          description = "GRPC listen port.";
          default = cfg.volume.port + 10000;
          type = port;
        };
        volumeSizeLimitMB = mkOption {
          description = "Size limit of a volume.";
          default = 30960;
          type = ints.unsigned;
        };
        allVolumesSizeMB = mkOption {
          description = "Size limit of all volumes combined.";
          default = 0;
          type = ints.unsigned;
        };
        indexDb = mkOption {
          description = ''
            Volume index backend.
            If using Rust volume server, it will be forced to `redb`. See [here](https://github.com/seaweedfs/seaweedfs/wiki/Rust-Volume-Server#index-backend).
          '';
          default = "leveldb";
          type = enum [
            "memory"
            "leveldb"
            "leveldbMedium"
            "leveldbLarge"
          ];
        };
        defaultReplicationStrategy = mkOption {
          description = "Default replication strategy. See [here](https://github.com/seaweedfs/seaweedfs/wiki/Replication#the-meaning-of-replication-type).";
          default = "000";
          type = str;
        };
        extraArgs = mkOption {
          description = "Extra arguments to be passed to `weed volume`.";
          default = [ ];
          type = listOf str;
        };
      };
      filer = {
        enable = mkEnableOption "SeaweedFS filer server";
        filerStoreConfig = mkOption {
          description = ''
            File containing configurations of filer metadata backend.
            This file will be linked to `/etc/seaweedfs/filer.toml`.
            A sample file can be generated with `nix run nixpkgs#seaweedfs -- scaffold -config=filer`.
            If not set, an embedded LevelDB store will be created at `$rootDir/filer`.
            See [here](https://github.com/seaweedfs/seaweedfs/wiki/Filer-Stores).
          '';
          default = null;
          type = nullOr str;
        };
        port = mkOption {
          description = "HTTP listen port.";
          default = 8888;
          type = port;
        };
        grpcPort = mkOption {
          description = "GRPC listen port.";
          default = cfg.filer.port + 10000;
          type = port;
        };
        extraArgs = mkOption {
          description = "Extra arguments to be passed to `weed filer`.";
          default = [ ];
          type = listOf str;
        };
      };
      S3Gateway = {
        enable = mkEnableOption "SeaweedFS S3 gateway";
        port = mkOption {
          description = "HTTP listen port.";
          default = 8333;
          type = port;
        };
        grpcPort = mkOption {
          description = "GRPC listen port.";
          default = cfg.S3Gateway.port + 10000;
          type = port;
        };
        filerAddr = mkOption {
          description = "Filer server to use. Will be ignored when using local filer server.";
          default = null;
          type = nullOr str;
        };
        s3ConfigFile = mkOption {
          description = ''
            File containing basic S3 IAM configurations, i.e. access keys.
            if both s3ConfigFile and iamConfigFile are not supplied, the gateway defaults to open access.
            See [S3 Configuration](https://github.com/seaweedfs/seaweedfs/wiki/S3-Configuration) and [S3 Credentials](https://github.com/seaweedfs/seaweedfs/wiki/S3-Credentials).
          '';
          default = null;
          type = nullOr str;
        };
        iamConfigFile = mkOption {
          description = ''
            File containing advanced S3 IAM configurations, i.e. OIDC, STS, IAM policies.
            See [here](https://github.com/seaweedfs/seaweedfs/wiki/OIDC-Integration).
          '';
          default = null;
          type = nullOr str;
        };
        extraArgs = mkOption {
          description = "Extra arguments to be passed to `weed s3`.";
          default = [ ];
          type = listOf str;
        };
      };
      adminUI = {
        enable = mkEnableOption "SeaweedFS admin UI server";
        port = mkOption {
          description = "HTTP listen port.";
          default = 23646;
          type = port;
        };
        grpcPort = mkOption {
          description = "GRPC listen port.";
          default = cfg.adminUI.port + 10000;
          type = port;
        };
        urlPrefix = mkOption {
          description = "URL path prefix for subdirectory deployment. Starts with forward slash.";
          default = null;
          type = nullOr str;
        };
        extraArgs = mkOption {
          description = "Extra arguments to be passed to `weed admin`.";
          default = [ ];
          type = listOf str;
        };
      };
      maintenance = {
        enable = mkEnableOption "SeaweedFS maintenance worker";
        extraArgs = mkOption {
          description = "Extra arguments to be passed to `weed worker`.";
          default = [ ];
          type = listOf str;
        };
      };
    };

  config =
    let
      pkgEnable =
        cfg.master.enable
        || cfg.volume.enable
        || cfg.filer.enable
        || cfg.S3Gateway.enable
        || cfg.adminUI.enable;

      seaweedfs-volume-rust = self.packages.x86_64-linux.seaweedfs-volume-rust;
      pkgExe = lib.meta.getExe cfg.package;
    in
    lib.mkIf pkgEnable {
      assertions = [
        {
          assertion = cfg.masters == [ ] -> cfg.master.enable;
          message = "Master server must run locally when there's no masters to join.";
        }
        {
          assertion =
            !cfg.filer.enable && cfg.S3Gateway.enable
            -> cfg.S3Gateway.filerAddr != null
            -> cfg.S3Gateway.filerAddr != "";
          message = "services.seaweed.S3Gateway.filerAddr must be set when local filer server is not enabled.";
        }
        {
          assertion = cfg.maintenance.enable -> cfg.adminUI.enable;
          message = "Maintenance worker must be used with local admin UI server.";
        }
      ];

      systemd.tmpfiles.settings = {
        "10-s3-dir".d =
          let
            dirs = [
              "${cfg.rootDir}"
            ]
            ++ lib.optional cfg.master.enable "${cfg.rootDir}/master"
            ++ lib.optional cfg.volume.enable "${cfg.rootDir}/volumes"
            ++ lib.optional cfg.filer.enable "${cfg.rootDir}/filer"
            ++ lib.optional cfg.adminUI.enable "${cfg.rootDir}/mgmtpanel";
            generator = _: {
              mode = "1750";
              user = cfg.user;
              group = cfg.user;
            };
          in
          lib.genAttrs dirs generator;
      }
      // lib.optionalAttrs (cfg.securityFile != null) {
        "15-s3-security"."L?" =
          let
            files = lib.map (c: "${cfg.rootDir}/${c}/security.toml") (
              lib.optional cfg.master.enable "master"
              ++ lib.optional cfg.volume.enable "volume"
              ++ lib.optional cfg.filer.enable "filer"
            );
            generator = _: { argument = cfg.securityFile; };
          in
          lib.genAttrs files generator;
      }
      // lib.optionalAttrs (cfg.filer.enable && cfg.filer.filerStoreConfig != null) {
        "16-s3-filerstore"."L?" = {
          "${cfg.rootDir}/filer/filer.toml".argument = cfg.filer.filerStoreConfig;
        };
      };

      environment.systemPackages = [
        cfg.package
      ]
      ++ lib.optional cfg.volume.useRustServer seaweedfs-volume-rust;

      users.users.${cfg.user} = {
        isSystemUser = true;
        group = cfg.user;
      };
      users.groups.${cfg.user} = { };

      systemd.services =
        let
          unit-commons = {
            wantedBy = [ "multi-user.target" ];
            after = [ "network.target" ];
          };
          service-commons = {
            User = cfg.user;
            Group = cfg.user;
            RestartSec = 10;
            Restart = "on-failure";
            MemoryDenyWriteExecute = true;
            NoNewPrivileges = true;
            LockPersonality = true;
            PrivateTmp = true;
            ProtectHome = true;
            ProtectSystem = "strict";
            ProtectClock = true;
            ProtectHostname = true;
            PrivateUsers = true;
            PrivateDevices = true;
            ProtectKernelLogs = true;
            ProtectKernelModules = true;
            ProtectKernelTunables = true;
            ProtectControlGroups = true;
            RestrictRealtime = true;
            RestrictSUIDSGID = true;
            RestrictAddressFamilies = [
              "AF_INET"
              "AF_INET6"
            ];
          };
          mastersList =
            if cfg.master.enable then
              lib.concatStringsSep "," (
                lib.pipe
                  [
                    "${cfg.listenAddr}:${toString cfg.master.port}"
                    cfg.master.peers
                  ]
                  [
                    lib.flatten
                    lib.uniqueStrings
                  ]
              )
            else
              lib.concatStringsSep "," cfg.masters;
        in
        lib.listToAttrs (
          lib.optional cfg.master.enable {
            name = "seaweedfs-master";
            value = unit-commons // {
              description = "SeaweedFS master server";
              serviceConfig = service-commons // {
                WorkingDirectory = "${cfg.rootDir}/master";
                ExecStart = lib.strings.concatStringsSep " " (
                  [
                    pkgExe
                    "master"
                    "-mdir=${cfg.rootDir}/master"
                    "-ip=${cfg.listenAddr}"
                    "-port=${toString cfg.master.port}"
                    "-port.grpc=${toString cfg.master.grpcPort}"
                    "-peers=${lib.concatStringsSep "," cfg.master.peers}"
                    "-volumeSizeLimitMB=${toString cfg.volume.volumeSizeLimitMB}"
                    "-defaultReplication=${cfg.volume.defaultReplicationStrategy}"
                  ]
                  ++ cfg.master.extraArgs
                );
              };
            };
          }
          ++ lib.optional cfg.volume.enable {
            name = "seaweedfs-volumes";
            value = unit-commons // {
              description = "SeaweedFS volume server";
              serviceConfig = service-commons // {
                WorkingDirectory = "${cfg.rootDir}/volume";
                ExecStart =
                  let
                    cmd = [
                      (
                        if cfg.volume.useRustServer then "${lib.meta.getExe seaweedfs-volume-rust}" else "${pkgExe} volume"
                      )
                      "-dir ${cfg.rootDir}/volumes"
                      "-max ${toString (cfg.volume.allVolumesSizeMB / cfg.volume.volumeSizeLimitMB)}"
                      "-ip ${cfg.listenAddr}"
                      "-port ${toString cfg.volume.port}"
                      "-port.grpc ${toString cfg.volume.grpcPort}"
                      "-master ${mastersList}"
                      "-dataCenter ${cfg.dataCenter}"
                      "-rack ${cfg.rack}"
                    ]
                    ++ lib.optional cfg.volume.useRustServer "-index redb"
                    ++ lib.optional (!cfg.volume.useRustServer) "-index ${cfg.volume.indexDb}"
                    ++ cfg.volume.extraArgs;
                  in
                  lib.strings.concatStringsSep " " cmd;
              };
            };
          }
          ++ lib.optional cfg.filer.enable {
            name = "seaweedfs-filer";
            value = unit-commons // {
              description = "SeaweedFS filer";
              serviceConfig = service-commons // {
                WorkingDirectory = "${cfg.rootDir}/filer";
                ExecStart =
                  let
                    cmd = [
                      pkgExe
                      "filer"
                      "-defaultStoreDir=${cfg.rootDir}/filer"
                      "-ip=${cfg.listenAddr}"
                      "-port=${toString cfg.filer.port}"
                      "-port.grpc=${toString cfg.filer.grpcPort}"
                      "-master=${mastersList}"
                    ]
                    ++ lib.optionals cfg.S3Gateway.enable (
                      [
                        "-s3"
                        "-s3.port=${toString cfg.S3Gateway.port}"
                        "-s3.port.grpc=${toString cfg.S3Gateway.grpcPort}"
                        "-s3.dataCenter=${cfg.dataCenter}"
                      ]
                      ++ lib.optional (cfg.S3Gateway.s3ConfigFile != null) "-s3.config=${cfg.S3Gateway.s3ConfigFile}"
                      ++ lib.optional (
                        cfg.S3Gateway.iamConfigFile != null
                      ) "-s3.iam.config=${cfg.S3Gateway.iamConfigFile}"
                    )
                    ++ cfg.filer.extraArgs;
                  in
                  lib.strings.concatStringsSep " " cmd;
              };
            };
          }
          ++ lib.optional (!cfg.filer.enable && cfg.S3Gateway.enable) {
            name = "seaweedfs-s3gateway";
            value = unit-commons // {
              description = "SeaweedFS S3 Gateway";
              serviceConfig = service-commons // {
                ExecStart =
                  let
                    cmd = [
                      pkgExe
                      "s3"
                      "-port=${toString cfg.S3Gateway.port}"
                      "-port.grpc=${toString cfg.S3Gateway.grpcPort}"
                      "-dataCenter=${cfg.dataCenter}"
                      "-filer=${cfg.S3Gateway.filerAddr}"
                    ]
                    ++ lib.optional (cfg.S3Gateway.s3ConfigFile != null) "-config=${cfg.S3Gateway.s3ConfigFile}"
                    ++ lib.optional (cfg.S3Gateway.iamConfigFile != null) "-iam.config=${cfg.S3Gateway.iamConfigFile}"
                    ++ cfg.S3Gateway.extraArgs;
                  in
                  lib.strings.concatStringsSep " " cmd;
              };
            };
          }
          ++ lib.optional cfg.adminUI.enable {
            name = "seaweedfs-admin";
            value = unit-commons // {
              description = "SeaweedFS admin UI";
              serviceConfig = service-commons // {
                WorkingDirectory = "${cfg.rootDir}/mgmtpanel";
                ExecStart =
                  let
                    cmd = [
                      pkgExe
                      "admin"
                      "-dataDir=${cfg.rootDir}/mgmtpanel"
                      "-port=${toString cfg.adminUI.port}"
                      "-port.grpc=${toString cfg.adminUI.grpcPort}"
                      "-master=${mastersList}"
                    ]
                    ++ lib.optional (cfg.adminUI.urlPrefix != null) "-urlPrefix=${cfg.adminUI.urlPrefix}"
                    ++ cfg.adminUI.extraArgs;
                  in
                  lib.strings.concatStringsSep " " cmd;
              };
            };
          }
          ++ lib.optional cfg.maintenance.enable {
            name = "seaweedfs-maint-worker";
            value = unit-commons // {
              description = "SeaweedFS maintenance worker";
              serviceConfig = service-commons // {
                ExecStart = lib.strings.concatStringsSep " " (
                  [
                    pkgExe
                    "worker"
                    "-admin=localhost:${toString cfg.adminUI.port}.${toString cfg.adminUI.grpcPort}"
                    "-workingDir=${cfg.rootDir}/mgmtpanel"
                  ]
                  ++ cfg.maintenance.extraArgs
                );
              };
            };
          }
        );
    };
}
