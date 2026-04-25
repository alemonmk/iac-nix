{
  lib,
  stdenv,
  buildGoModule,
  fetchFromGitHub,
}:
let
  buildAttrFn =
    {
      name,
      version,
      hash,
    }:
    let
      subPackage = lib.strings.replaceStrings [ "-" ] [ "/" ] name;
      mainProgram = "openbao-plugins-${name}-${stdenv.targetPlatform.go.GOARCH}";
    in
    (finalAttrs: {
      pname = "openbao-plugins-${name}";
      inherit version;
      src = fetchFromGitHub {
        owner = "openbao";
        repo = "openbao-plugins";
        tag = "${name}-v${version}";
        inherit hash;
      };
      vendorHash = null;

      ldflags = [
        "-s"
        "-w"
        "-X github.com/openbao/openbao-plugins/${subPackage}.pluginVersion=v${version}"
      ];
      subPackages = [ "${subPackage}/cmd" ];

      # riduclously needed because https://github.com/golang/go/issues/48489 has been stale for 5 years
      postBuild = "mv $GOPATH/bin/cmd $GOPATH/bin/${mainProgram}";

      meta = {
        changelog = "https://github.com/openbao/openbao-plugins/releases/tag/${name}-v${version}";
        description = "OpenBao plugin providing ${name}";
        homepage = "https://github.com/openbao/openbao-plugins";
        license = lib.licenses.mpl20;
        maintainers = with lib.maintainers; [ alemonmk ];
        inherit mainProgram;
      };
    });
  buildOpenBaoPlugin = info: info |> buildAttrFn |> buildGoModule;
in
lib.mapAttrs'
  (
    n: v:
    let
      pkg = buildOpenBaoPlugin v;
    in
    lib.nameValuePair pkg.pname pkg
  )
  {
    auth-aws = {
      name = "auth-aws";
      version = "0.1.1";
      hash = "sha256-fOFGjEhX+vqPN5JcJ0240QBtMO6opcoVMz68zIKAIuA=";
    };
    auth-azure = {
      name = "auth-azure";
      version = "0.23.0";
      hash = "sha256-XdyOvP6IILbzm1JWqdcrVdLYEG6VKqe2Wh6XmhLrZyw=";
    };
    auth-gcp = {
      name = "auth-gcp";
      version = "0.22.0";
      hash = "sha256-XdyOvP6IILbzm1JWqdcrVdLYEG6VKqe2Wh6XmhLrZyw=";
    };
    auth-github = {
      name = "auth-github";
      version = "0.0.1";
      hash = "sha256-deU9pjtvDA26MUJL+LJjEZEuoqmYWadIsMvVxvLVj1w=";
    };
    secrets-aws = {
      name = "secrets-aws";
      version = "0.3.0-beta20260326";
      hash = "sha256-u/2Udv+31yfvoLl4F36x8ONy93HNO7rpt8pm4Z7OmIQ=";
    };
    secrets-azure = {
      name = "secrets-azure";
      version = "0.23.0";
      hash = "sha256-u/2Udv+31yfvoLl4F36x8ONy93HNO7rpt8pm4Z7OmIQ=";
    };
    secrets-consul = {
      name = "secrets-consul";
      version = "0.1.0";
      hash = "sha256-ntFWKmKd6mBgvnQ6UGIou+WTuhahh3EMl9o9F5+T3Ik=";
    };
    secrets-gcp = {
      name = "secrets-gcp";
      version = "0.23.0";
      hash = "sha256-XdyOvP6IILbzm1JWqdcrVdLYEG6VKqe2Wh6XmhLrZyw=";
    };
    secrets-gcpkms = {
      name = "secrets-gcpkms";
      version = "0.21.0";
      hash = "sha256-XdyOvP6IILbzm1JWqdcrVdLYEG6VKqe2Wh6XmhLrZyw=";
    };
    secrets-nomad = {
      name = "secrets-nomad";
      version = "0.1.5";
      hash = "sha256-phHeaZ3nK7M277VXvHkqw3kqXw9zlR0u5ykMexSOZ+0=";
    };
  }
