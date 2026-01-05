{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  buildGoModule,
  nodejs,
  fetchYarnDeps,
  yarnConfigHook,
  yarnBuildHook,
}:
buildGoModule (
  finalAttrs:
  let
    gitness-web = stdenvNoCC.mkDerivation {
      pname = "gitness-web";
      version = finalAttrs.version;

      src = finalAttrs.src;
      sourceRoot = "${finalAttrs.src.name}/web";

      yarnOfflineCache = fetchYarnDeps {
        yarnLock = "${finalAttrs.src}/web/yarn.lock";
        hash = "sha256-R3ffE+9YTupnr7YrJCHLWibuUFM2waRV34mu5k8ismk=";
      };

      nativeBuildInputs = [
        yarnConfigHook
        yarnBuildHook
        nodejs
      ];

      installPhase = ''cp -R dist $out'';
    };
  in
  {
    pname = "gitness";
    version = "3.3.0-unstable-2026-01-05";

    src = fetchFromGitHub {
      owner = "harness";
      repo = "harness";
      rev = "27e2398ff905192845c741116b1aebf084c6549e";
      hash = "sha256-cSral9HxbJJtNnL/p3z8SPXk8Yf9pz4CjqglEcmobjk=";
    };

    vendorHash = "sha256-erz2EylnPYKCWF5jnmD7kKiR735H0cAmi9OSmwmtMC8=";

    preBuild = ''cp -R ${gitness-web} web/dist'';

    subPackages = [ "cmd/gitness" ];

    meta = {
      description = "An end-to-end developer platform with Source Control Management, CI/CD Pipelines, Hosted Developer Environments, and Artifact Registries";
      homepage = "https://www.harness.io/open-source";
      license = lib.licenses.asl20;
      maintainers = with lib.maintainers; [ alemonmk ];
      platforms = lib.platforms.linux ++ lib.platforms.darwin;
      mainProgram = "gitness";
    };
  }
)
