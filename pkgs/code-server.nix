{
  lib,
  stdenvNoCC,
  fetchzip,
  nixosTests,
  nodejs,
}:
stdenvNoCC.mkDerivation (
  finalAttrs: {
    pname = "code-server";
    version = "4.96.4";

    src = fetchzip {
      url = "https://github.com/coder/code-server/releases/download/v${finalAttrs.version}/code-server-${finalAttrs.version}-linux-amd64.tar.gz";
      hash = "sha256-EFCmPnlq1j18xERDFw9mS8iUNP9Pk5Vo7NL05I71jbA=";
    };

    dontPatch = true;
    dontConfigure = true;
    dontBuild = true;
    installPhase = ''
      mkdir -p $out
      rm lib/node
      ln -s ${nodejs}/bin/node lib/node
      cp -R . $out
    '';

    passthru = {
      tests = {
        inherit (nixosTests) code-server;
      };
      executableName = "code-server";
      longName = "Visual Studio Code Server";
    };

    meta = {
      changelog = "https://github.com/coder/code-server/blob/v${finalAttrs.version}/CHANGELOG.md";
      description = "Run VS Code on a remote server";
      longDescription = ''
        code-server is VS Code running on a remote server, accessible through the
        browser.
      '';
      homepage = "https://github.com/coder/code-server";
      license = lib.licenses.mit;
      maintainers = with lib.maintainers; [
        offline
        henkery
        code-asher
      ];
      platforms = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
      ];
      mainProgram = "code-server";
    };
  }
)
