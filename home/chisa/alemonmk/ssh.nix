{ lib, ... }:
{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings = {
      "!*.snct.rmntn.net *.shitara.rmntn.net *.rmntn.net" = {
        User = "emergency";
        Port = 444;
        IdentityFile = "~/.ssh/kotone.key";
        PreferredAuthentications = "publickey";
      };
      "*.snct.rmntn.net" = {
        User = "dsvcadmin@snct.rmntn.net";
      };
      "10.* 172.16.* 192.168.*" = {
        StrictHostKeyChecking = "no";
        UserKnownHostsFile = "/dev/null";
      };
      "*" = {
        ForwardAgent = false;
        AddKeysToAgent = "no";
        Compression = false;
        ServerAliveInterval = 0;
        ServerAliveCountMax = 3;
        HashKnownHosts = false;
        UserKnownHostsFile = "~/.ssh/known_hosts";
        ControlMaster = "no";
        ControlPath = "~/.ssh/master-%r@%n:%p";
        ControlPersist = "no";
      };
    };
  };
}
