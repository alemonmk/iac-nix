{ flakeRoot, ... }:
{
  networking.hosts."10.85.29.2" = [ "vdi.snct.rmntn.net" ];

  security.pki.certificateFiles = [
    "${flakeRoot}/blobs/pki/g1.crt"
    "${flakeRoot}/blobs/pki/vmvcs.crt"
  ];

  services = {
    victoriametrics = {
      enable = true;
      retentionPeriod = "2y";
      listenAddress = "localhost:8428";
      extraOptions = [
        "-selfScrapeInterval=15s"
        "-promscrape.config.strictParse=false"
        "-promscrape.config=${flakeRoot}/blobs/monitoring/victoriametrics/scrape.yml"
      ];
    };

    prometheus.exporters.blackbox = {
      enable = true;
      listenAddress = "127.0.0.1";
      # has to use string concat due to weird path concat in module
      configFile = flakeRoot + "/blobs/monitoring/victoriametrics/blackbox.yml";
    };
  };

  environment.persistence."/nix/persist".directories = [ "/var/lib/private/victoriametrics" ];
}
