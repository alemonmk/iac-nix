{
  flakeRoot,
  config,
  lib,
  pkgs,
  nixpkgs-next,
  ...
}:
let
  inherit (lib.modules) mkDefault;
  enabled = config.services.seaweedfs.dataCenter != null;
in
{
  config = lib.modules.mkIf enabled {
    services.seaweedfs = {
      rootDir = "/s3";
      package = nixpkgs-next.seaweedfs;
      # securityFile = config.sops.secrets.seaweedfs-security.path;
      master = {
        enable = mkDefault true;
        port = 5300;
        grpcPort = 5310;
      };
      volume = {
        enable = mkDefault true;
        useRustServer = mkDefault true;
        port = 5301;
        grpcPort = 5311;
        volumeSizeLimitMB = 4096;
        defaultReplicationStrategy = mkDefault {
          toOtherDatacenters = 1;
          toOtherRacks = 1;
          toOwnRack = 0;
        };
      };
      filer = {
        enable = mkDefault true;
        filerStoreConfig =
          (pkgs.writeTextFile {
            name = "filer-config";
            text = ''
              [filer.options]
              recursive_delete = false
              [leveldb3]
              enabled = true
              dir = "./db"
            '';
          }).outPath;
        port = 5302;
        grpcPort = 5312;
      };
      S3Gateway = {
        enable = mkDefault true;
        port = 5304;
        grpcPort = 5314;
      };
      adminUI = {
        enable = mkDefault true;
        port = 5305;
        grpcPort = 5315;
        urlPrefix = "/management";
      };
      maintenance = {
        enable = mkDefault true;
      };
    };

    services.caddy = {
      virtualHosts."objects.snct.rmntn.net" = {
        extraConfig =
          let
            addr-s3gateway = config.services.seaweedfs.listenAddr;
            route-adminui = config.services.seaweedfs.adminUI.urlPrefix;
            port-adminui = toString config.services.seaweedfs.adminUI.port;
            port-s3gateway = toString config.services.seaweedfs.S3Gateway.port;
          in
          ''
            reverse_proxy ${route-adminui}/* localhost:${port-adminui}
            reverse_proxy ${addr-s3gateway}:${port-s3gateway}
          '';
      };
    };
  };
}
