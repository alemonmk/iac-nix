{
  lib,
  stdenv,
  fetchzip,
  srcOnly,
  nixosTests,
  nodejs_22,
  nodejsSrc_22 ? srcOnly nodejs_22,
  python313,
  node-gyp,
  node-pre-gyp,
  krb5,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "code-server";
  version = "4.101.2";

  src = fetchzip {
    url = "https://github.com/coder/code-server/releases/download/v${finalAttrs.version}/code-server-${finalAttrs.version}-linux-amd64.tar.gz";
    hash = "sha256-YegoXynLE8JH//GXQgdvtabqF2Qwf4QwLq3QUWv+PEY=";
  };

  dontPatch = true;
  dontConfigure = true;
  nativeBuildInputs = [
    nodejsSrc_22
    python313
    node-gyp
    node-pre-gyp
    krb5
  ];
  buildInputs = [ nodejs_22 ];
  buildPhase = ''
    node-pre-gyp rebuild --nodedir=${nodejsSrc_22} -C ./node_modules/argon2
    node-gyp rebuild --nodedir=${nodejsSrc_22} -C ./lib/vscode/node_modules/@vscode/spdlog
    node-gyp rebuild --nodedir=${nodejsSrc_22} -C ./lib/vscode/node_modules/@parcel/watcher
    node-gyp rebuild --nodedir=${nodejsSrc_22} -C ./lib/vscode/node_modules/node-pty
    CXXFLAGS="-I${krb5.dev}/include" node-gyp rebuild --nodedir=${nodejsSrc_22} -C ./lib/vscode/node_modules/kerberos
    rm -r ./lib/vscode/node_modules/@parcel/watcher-linux-x64-{glibc,musl}
  '';
  installPhase = ''
    mkdir -p $out
    rm lib/node
    ln -s ${nodejs_22}/bin/node lib/node
    ln -s node_modules node_modules.asar
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
    maintainers = with lib.maintainers; [ ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "code-server";
  };
})
