{
  programs.ssh = {
    enable = true;
    matchBlocks = {
      "newdc.rmntn.net" = {
        host = "!*.snct.rmntn.net *.shitara.rmntn.net";
        user = "emergency";
        port = 444;
        identityFile = "~/.ssh/kotone.key";
        extraOptions = {
          PreferredAuthentications = "publickey";
        };
      };
      "public.rmntn.net" = {
        host = "!*.snct.rmntn.net *.rmntn.net";
        user = "monoremonton";
        port = 444;
        identityFile = "~/.ssh/kotone.key";
        extraOptions = {
          PreferredAuthentications = "publickey";
        };
      };
      "private.rmntn.net" = {
        host = "*.snct.rmntn.net";
        user = "dsvcadmin@snct.rmntn.net";
      };
      "ignore-hostkey" = {
        host = "10.* 172.16.* 192.168.*";
        extraOptions = {
          StrictHostKeyChecking = "no";
          userKnownHostsFile = "/dev/null";
        };
      };
    };
  };
}
