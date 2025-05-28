{lib, ...}: {
  users.ms-ad = {
    enable = lib.mkDefault true;
    domain = "snct.rmntn.net";
  };
}
