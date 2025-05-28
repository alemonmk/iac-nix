{config, ...}: {
  environment.persistence."/nix/persist" = {
    directories = [
      "/var/lib/nixos"
      "/var/log"
    ];
    files = [
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_ed25519_key.pub"
      "/etc/machine-id"
    ];
  };

  fileSystems."/nix".neededForBoot = true;

  boot.initrd.postResumeCommands = ''
    mkdir -p /mnt/btrfs_root
    mount -o subvol=/ /dev/disk/by-partlabel/ROOT /mnt/btrfs_root

    echo "Deleteing sub-subvolumes..."
    btrfs subvolume list -o /mnt/btrfs_root/rootfs |
    cut -f9 -d' ' |
    while read subvolume; do
      echo "deleting /$subvolume subvolume..."
      btrfs subvolume delete "/mnt/btrfs_root/$subvolume"
    done &&

    echo "Deleting rootfs subvolume..."
    btrfs subvolume delete /mnt/btrfs_root/rootfs

    echo "Restoring blank rootfs subvolume..."
    btrfs subvolume snapshot /mnt/btrfs_root/rootfs-0 /mnt/btrfs_root/rootfs

    umount /mnt/btrfs_root
  '';
}
