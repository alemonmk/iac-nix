final: prev: {
  squid = prev.squid.overrideAttrs (old: {
    configureFlags = 
      (prev.lib.lists.remove "--enable-ipv6" old.configureFlags)
      ++ ["--disable-ipv6" "--disable-esi"];
  });
}
