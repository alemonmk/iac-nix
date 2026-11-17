{
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

  boot.initrd.systemd.services.wipe-root = {
    # Specify dependencies explicitly
    unitConfig.DefaultDependencies = false;
    # The script needs to run to completion before this service is done
    serviceConfig.Type = "oneshot";
    # This service is required for boot to succeed
    wantedBy = [ "initrd.target" ];
    # Should complete before any file systems are mounted
    before = [ "sysroot.mount" ];

    # Wait for the disk to appear
    requires = [
      "${utils.escapeSystemdPath "/dev/disk/by-partlabel/ROOT"}.device"
    ];
    after = [
      "${utils.escapeSystemdPath "/dev/disk/by-partlabel/ROOT"}.device"
    ];

    script = ''
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
  };
}
