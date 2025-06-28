{
  systemd.network.networks = {
    "1-ens192" = {
      matchConfig.Name = "ens192";
      address = ["10.85.10.5/27"];
      gateway = ["10.85.10.30"];
      networkConfig = {
        LLDP = false;
        IPv6AcceptRA = false;
      };
    };
    "2-ens224" = {
      matchConfig.Name = "ens224";
      address = ["10.88.0.2/24"];
    };
  };

  services.caddy.enable = true;

  imports = [
    ./secrets.nix
    ./metrics.nix
    ./telegraf.nix
    ./log-receiver.nix
    ./oxidized.nix
    ./grafana.nix
  ];
}
