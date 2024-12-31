{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule rec {
  pname = "chrony-exporter";
  version = "0.11.0";

  src = fetchFromGitHub {
    owner = "SuperQ";
    repo = "chrony_exporter";
    rev = "5079704a720fdc8d592b6c4e97de0ced2b980b2b";
    sha256 = "sha256-xHI0BYli82cCGFtv58jJ+PpjR/q1ReWjUqRDtp89w+Y=";
  };

  vendorHash = "sha256-czAkqEeGRSdMJmSZNwzAMAk045p4aog4XOQUU48jeOo=";

  meta = with lib; {
    description = "Prometheus Exporter for Chrony NTP.";
    mainProgram = "chrony_exporter";
    homepage = "https://github.com/SuperQ/chrony_exporter";
    license = licenses.asl20;
    maintainers = [];
  };
}
