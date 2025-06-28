{ nixpkgs-next, ... }:
{
  environment.systemPackages = [ nixpkgs-next.yt-dlp ];

  services = {
    jellyfin.enable = true;

    caddy.virtualHosts."ytarc.snct.rmntn.net".extraConfig = "reverse_proxy /playback/* localhost:8096";
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
