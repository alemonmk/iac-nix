{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./hardware.nix
    ./nix.nix
    ./security.nix
    ./networking.nix
    ./debloats.nix
    ./impermenance.nix
  ];

  system.stateVersion = "24.11";

  time.timeZone = "Asia/Taipei";
  i18n.defaultLocale = "en_US.UTF8";

  services.fstrim.enable = true;

  boot.kernelPackages = pkgs.linuxPackages_zen;

  programs.mtr.enable = true;
  environment.systemPackages = [pkgs.dnsutils pkgs.git];
}
