{
  networking.nftables = {
    enable = true;
    flushRuleset = true;
    tables.global = {
      family = "inet";
      content = ''
        chain input {
          type filter hook input priority filter; policy drop;
          iif "lo" accept
          ct state vmap { established : accept, related : accept, invalid : drop }
          icmp type {destination-unreachable, echo-request, time-exceeded, parameter-problem } limit rate 5/second counter accept
          udp dport 33434-33523 reject with icmpx type port-unreachable
          icmpv6 type { destination-unreachable, echo-request, time-exceeded, parameter-problem, packet-too-big, nd-router-advert, nd-neighbor-solicit, nd-neighbor-advert } counter accept
          ip saddr 10.85.20.11 tcp dport ssh counter accept
          jump service-input
        }
      '';
    };
  };
}
