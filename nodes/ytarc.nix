{
  config,
  lib,
  pkgs,
  nixpkgs-next,
  ...
}: {
  networking = {
    hostName = "rmnmvytarc";
    interfaces.ens192.ipv4.addresses = [
      {
        address = "10.85.20.8";
        prefixLength = 26;
      }
    ];
    defaultGateway = {address = "10.85.20.62";};
    interfaces.ens192.ipv6.addresses = [
      {
        address = "2400:8902:e002:59e3::a34:910e";
        prefixLength = 64;
      }
    ];
    defaultGateway6 = {address = "2400:8902:e002:59e3::ccef";};
  };

  environment.systemPackages = [nixpkgs-next.yt-dlp];

  virtualisation = {
    podman = {
      enable = true;
      dockerCompat = true;
    };
  };

  fileSystems."/mnt/pfs3/ytarchive" = {
    device = "rmnmpfss03.snct.rmntn.net:/volume1/YoutubeArchive";
    fsType = "nfs";
    options = ["nfsvers=4.1"];
  };

  virtualisation.oci-containers.containers = {
    "metube" = {
      image = "ghcr.io/alexta69/metube:2025-05-01";
      extraOptions = ["--network=host"];
      environment = {
        UID = "2500";
        GID = "2500";
        URL_PREFIX = "/archiver/";
        OUTPUT_TEMPLATE = "%(uploader)s/%(upload_date>%Y)s/[%(upload_date>%y%m%d)s][%(id)s].%(ext)s";
        DOWNLOAD_MODE = "sequential";
        YTDL_OPTIONS = "{\"verbose\":true,\"cookiefile\":\"/app/cookies.txt\",\"proxy\":\"http://rmnmvwebgw.snct.rmntn.net:3128\",\"source_address\":\"0.0.0.0\",\"writeinfojson\":true,\"writesubtitles\":true,\"subtitleslangs\":[\"en\",\"zh-tw\",\"-live_chat\"],\"postprocessors\":[{\"key\":\"FFmpegEmbedSubtitle\",\"already_have_subtitle\":false},{\"key\":\"FFmpegMetadata\",\"add_chapters\":true}]}";
      };
      volumes = [
        "/mnt/pfs3/ytarchive:/downloads"
        "/nix/persist/opt/metube/.cache:/.cache"
        "/nix/persist/opt/metube/cookies.txt:/app/cookies.txt"
      ];
    };
  };

  services = {
    jellyfin = {
      enable = true;
    };
    caddy = {
      enable = true;
      virtualHosts = {
        "ytarc.snct.rmntn.net" = {
          extraConfig = ''
            reverse_proxy /archiver/* localhost:8081 {
                    header_up X-Real-IP {remote_host}
            }

            reverse_proxy /playback/* localhost:8096 {
                    header_up X-Real-IP {remote_host}
            }
          '';
        };
      };
    };
  };

  systemd.services.jellyfin.environment = {
    http_proxy = "http://10.85.20.10:3128";
    https_proxy = "http://10.85.20.10:3128";
  };

  environment.persistence."/nix/persist" = {
    directories = [
      "/var/cache/jellyfin"
      "/var/lib/jellyfin"
    ];
  };
}
