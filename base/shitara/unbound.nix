{lib, ...}: {
  services.resolved = {
    enable = true;
    llmnr = "false";
    fallbackDns = ["127.0.0.1" "::1"];
  };

  services.unbound = {
    enable = true;
    settings = {
      server = let
        private-domains = [
          "consul"
          "snct.rmntn.net"
          "10.in-addr.arpa"
        ];
      in {
        do-not-query-localhost = true;
        unblock-lan-zones = true;
        insecure-lan-zones = true;
        private-domain = private-domains;
        domain-insecure = private-domains;
      };
      forward-zone = [
        {
          name = "consul";
          forward-addr =
            builtins.map
            (x: "10.85.183.${builtins.toString x}@8600")
            (lib.lists.range 1 5);
        }
      ];
      stub-zone =
        builtins.map
        (d: {
          name = d;
          stub-addr = ["10.85.11.1" "10.85.11.2"];
        })
        ["snct.rmntn.net" "10.in-addr.arpa"];
    };
  };
}
