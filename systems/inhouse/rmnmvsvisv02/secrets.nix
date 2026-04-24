{
  flakeRoot,
  config,
  pkgs,
  ...
}:
{
  sops.secrets = {
    vault-mtls-key.sopsFile = flakeRoot + /secrets/secrets-vault/mtls-crt-key.yaml;
    unseal-token-1.sopsFile = flakeRoot + /secrets/secrets-vault/unseal-tokens-b.yaml;
    unseal-token-2.sopsFile = flakeRoot + /secrets/secrets-vault/unseal-tokens-b.yaml;
  };
  sops.templates."auto-unseal-conf" = {
    file = pkgs.replaceVarsWith {
      src = flakeRoot + /blobs/secrets-vault/auto-unseal.yaml;
      replacements = {
        unseal-token-1 = config.sops.placeholder.unseal-token-1;
        unseal-token-2 = config.sops.placeholder.unseal-token-2;
      };
    };
  };
}
