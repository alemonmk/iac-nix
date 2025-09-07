{
  lib,
  python313Packages,
  fetchFromGitHub,
  bgpq4,
  bird3,
  ...
}:
python313Packages.buildPythonApplication {
  pname = "vpn-route-gen";
  version = "0.0.3";
  pyproject = true;

  src = ./.;

  postPatch = ''
    substituteInPlace routegen.py \
      --replace-fail "/usr/bin/bgpq4" "${lib.getExe bgpq4}" \
      --replace-fail "/usr/sbin/birdc" "${bird3}/bin/birdc"
  '';

  nativeBuildInputs = with python313Packages; [ setuptools ];
  propagatedBuildInputs = with python313Packages; [
    aggregate6
    dnspython
  ];

  meta = {
    description = "Build static routes with various sources to be used in Bird";
    mainProgram = "vpn-route-gen";
    homepage = "";
    license = with lib.licenses; [ gpl2Only ];
    maintainers = with lib.maintainers; [ ];
  };
}
