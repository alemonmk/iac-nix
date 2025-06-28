{ lib, ... }:
{
  users.ms-ad = {
    enable = lib.mkDefault true;
    domain = "snct.rmntn.net";
    sudoers = [
      {
        groups = [ "sg\\ server\\ administrators@snct.rmntn.net" ];
        commands = [ "ALL" ];
      }
    ];
  };
}
