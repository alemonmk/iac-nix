#!/run/current-system/sw/bin/bash
cp -R /var/lib/nixos /nix/persist/var/lib/nixos
cp /etc/ssh/ssh_host_ed25519_key /nix/persist/ssh/ssh_host_ed25519_key
cp /etc/ssh/ssh_host_ed25519_key.pub /nix/persist/ssh/ssh_host_ed25519_key.pub
cp /etc/machine-id /nix/persist/etc/machine-id

echo "Showing SSH host public key for sops-nix deployment:"
cat /nix/persist/ssh/ssh_host_ed25519_key.pub

exit 0
