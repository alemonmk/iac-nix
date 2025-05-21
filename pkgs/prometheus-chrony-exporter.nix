{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule {
  pname = "chrony-exporter";
  version = "0.12.0";

  src = fetchFromGitHub {
    owner = "SuperQ";
    repo = "chrony_exporter";
    rev = "f95d00763f6291742e51326402102ffd68d6d5cf";
    sha256 = "sha256-ZXqCZZx0UG8050SYgVwD+wnTX0N41Bjv1dhdQmOHmR4=";
  };

  vendorHash = "sha256-3zL7BrCdMVnt7F1FiZ2eQnKVhmCeW3aYKKX9v01ms/k=";

  meta = {
    description = "Prometheus Exporter for Chrony";
    homepage = "https://github.com/SuperQ/chrony_exporter";
    license = lib.licenses.asl20;
    platforms = lib.platforms.linux;
    mainProgram = "chrony_exporter";
    maintainers = with lib.maintainers; [];
  };
}
