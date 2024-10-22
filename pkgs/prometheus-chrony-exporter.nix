{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule rec {
  pname = "chrony-exporter";
  version = "0.10.1";

  src = fetchFromGitHub {
    owner = "SuperQ";
    repo = "chrony_exporter";
    rev = "cdc0e9642fc3a55c53b7b52eb66ee0bf37f1061b";
    sha256 = "sha256-EDYvC3tucGzLb+OxCA8yiVsPU8ai3bXTzzp39qIsAr8=";
  };

  vendorHash = "sha256-HLSa0CvUgEaK8Htmgm5QWNRWAFZGALNPNLr2zeJwU3c=";

  meta = with lib; {
    description = "Prometheus Exporter for Chrony NTP.";
    mainProgram = "chrony_exporter";
    homepage = "https://github.com/SuperQ/chrony_exporter";
    license = licenses.asl20;
    maintainers = [];
  };
}
