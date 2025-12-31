{ flakeRoot, pkgs, ... }:
{
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
  };

  virtualisation.oci-containers.containers."metube" = {
    image = "metube-pot-plugin:2025.12.27";
    imageFile = pkgs.metube;
    networks = [ "host" ];
    capabilities.all = false;
    user = "2500:2500";
    environment = {
      URL_PREFIX = "/archiver/";
      OUTPUT_TEMPLATE = "%(uploader)s/%(upload_date>%Y)s/[%(upload_date>%y%m%d)s][%(id)s].%(ext)s";
      DOWNLOAD_MODE = "sequential";
      YTDL_OPTIONS_FILE = "/app/ytdlp-options.json";
    };
    volumes = [
      "/mnt/pfs3/ytarchive:/downloads"
      "/nix/persist/opt/metube/cookies.txt:/app/cookies.txt"
      "${flakeRoot}/blobs/youtube-archiver/ytdlp-options.json:/app/ytdlp-options.json"
    ];
  };
  virtualisation.oci-containers.containers."pot-provider" = {
    image = "brainicism/bgutil-ytdlp-pot-provider";
    networks = [ "host" ];
    capabilities.all = false;
  };

  services.caddy.virtualHosts."ytarc.snct.rmntn.net".extraConfig =
    "reverse_proxy /archiver/* localhost:8081";
}
