final: prev: {
  jellyfin-ffmpeg = final.callPackage ../pkgs/jellyfin-ffmpeg.nix {};
  prometheus-chrony-exporter = final.callPackage ../pkgs/prometheus-chrony-exporter.nix {};
  oxidized = final.callPackage ../pkgs/oxidized/default.nix {};
}
