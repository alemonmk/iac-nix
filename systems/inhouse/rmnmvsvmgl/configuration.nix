{pkgs, ...}: {
  systemd.network.networks."1-ens192" = {
    matchConfig.Name = "ens192";
    address = [
      "10.85.20.11/26"
      "2400:8902:e002:59e3::c:4d79/64"
    ];
    gateway = [
      "10.85.20.62"
      "2400:8902:e002:59e3::ccef"
    ];
    networkConfig.LLDP = false;
  };

  environment.systemPackages = with pkgs; [
    alejandra
    sops
  ];

  services.caddy.enable = true;

  imports = [
    ./secrets.nix
    ./code-server.nix
    ./hydra-binary-cache.nix
  ];
}
