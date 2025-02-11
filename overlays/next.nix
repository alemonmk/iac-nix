final: prev: {
  squid = prev.squid.overrideAttrs (old: {
    src = prev.fetchurl {
      url = "https://github.com/squid-cache/squid/releases/download/SQUID_6_13/squid-6.13.tar.xz";
      hash = "sha256-Iy4FZ5RszAEVZTw8GPAeg/LZzEnEPZ3q2LMZrws1rVI=";
    };
    configureFlags =
      (prev.lib.lists.remove "--enable-ipv6" old.configureFlags)
      ++ ["--disable-ipv6"];
  });

  technitium-dns-server-library = prev.technitium-dns-server-library.overrideAttrs (old: rec {
    version = "dns-server-v13.4";
    src = prev.fetchFromGitHub {
      owner = "TechnitiumSoftware";
      repo = "TechnitiumLibrary";
      tag = version;
      hash = "sha256-mNWEQAN7T29GmX3mGPrJ5GhELUYNJTvUAhyEWZwN5Vw=";
      name = "${old.pname}-${version}";
    };
  });

  technitium-dns-server = prev.technitium-dns-server.overrideAttrs (old: rec {
    version = "13.4";
    src = prev.fetchFromGitHub {
      owner = "TechnitiumSoftware";
      repo = "DnsServer";
      tag = "v${version}";
      hash = "sha256-ikq+0n/VqSxG2Hnn802EkHFpmsn25expBQnTJ69gktk=";
      name = "${old.pname}-${version}";
    };
    patches = [
      ../blobs/technitium-dns-server/webReqProxy.patch
    ];
  });

  code-server = prev.stdenvNoCC.mkDerivation (
    finalAttrs: {
      pname = "code-server";
      version = "4.96.4";

      src = prev.fetchzip {
        url = "https://github.com/coder/code-server/releases/download/v${finalAttrs.version}/code-server-${finalAttrs.version}-linux-amd64.tar.gz";
        hash = "sha256-EFCmPnlq1j18xERDFw9mS8iUNP9Pk5Vo7NL05I71jbA=";
      };

      dontPatch = true;
      dontConfigure = true;
      dontBuild = true;
      installPhase = ''
        mkdir -p $out
        rm lib/node
        ln -s ${prev.nodejs}/bin/node lib/node
        cp -R . $out
      '';

      passthru = {
        tests = {
          inherit (prev.nixosTests) code-server;
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
        license = prev.lib.licenses.mit;
        maintainers = with prev.lib.maintainers; [
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
  );
}
