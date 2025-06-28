{
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
  };

  virtualisation.oci-containers.containers."metube" = {
    image = "ghcr.io/alexta69/metube:2025-06-26";
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

  services.caddy.virtualHosts."ytarc.snct.rmntn.net".extraConfig = "reverse_proxy /archiver/* localhost:8081";
}
