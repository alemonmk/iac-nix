{ flakeRoot, ... }:
{
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
  };

  virtualisation.oci-containers.containers."metube" = {
    image = "ghcr.io/alexta69/metube:2025.10.23";
    extraOptions = [ "--network=host" ];
    environment = {
      UID = "2500";
      GID = "2500";
      URL_PREFIX = "/archiver/";
      OUTPUT_TEMPLATE = "%(uploader)s/%(upload_date>%Y)s/[%(upload_date>%y%m%d)s][%(id)s].%(ext)s";
      DOWNLOAD_MODE = "sequential";
      YTDL_OPTIONS_FILE = "/app/ytdlp-options.json";
    };
    volumes = [
      "/mnt/pfs3/ytarchive:/downloads"
      "/nix/persist/opt/metube/.cache:/.cache"
      "/nix/persist/opt/metube/cookies.txt:/app/cookies.txt"
      "${flakeRoot}/blobs/youtube-archiver/ytdlp-options.json:/app/ytdlp-options.json"
    ];
  };

  services.caddy.virtualHosts."ytarc.snct.rmntn.net".extraConfig =
    "reverse_proxy /archiver/* localhost:8081";
}
