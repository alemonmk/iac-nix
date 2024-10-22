{
  programs.ssh = {
    enable = true;
    matchBlocks = {
      "public.rmntn.net" = {
        host = "!*.snct.rmntn.net *.rmntn.net";
        user = "monoremonton";
        port = 444;
        identityFile = "~/.ssh/kotone.key";
        extraOptions = {
          PreferredAuthentications = "publickey";
        };
      };
      "ignore-hostkey" = {
        host = "10.1.1.* 192.168.1.*";
        extraOptions = {
          StrictHostKeyChecking = "no";
          userKnownHostsFile = "/dev/null";
        };
      };
    };
  };
}
