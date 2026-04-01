final: prev: {
  opensmtpd = prev.opensmtpd.overrideAttrs (old: {
    patches = old.patches ++ [ ./opensmtpd-proc-path.diff ];
  });
}
