{
  disko.devices.disk.sda = {
    device = "/dev/sda";
    type = "disk";
    content = {
      type = "gpt";
      partitions = {
        a-efi = {
          type = "EF00";
          start = "1M";
          size = "512M";
          label = "EFI";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = ["umask=0077"];
          };
        };
        b-root = {
          size = "4G";
          label = "ROOT";
          content = {
            type = "btrfs";
            subvolumes = {
              "/rootfs" = {
                mountpoint = "/";
                mountOptions = ["noatime"];
              };
            };
          };
        };
        c-nix-store = {
          end = "-4G";
          label = "NIX";
          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/nix";
            mountOptions = ["noatime"];
          };
        };
        d-swap = {
          size = "100%";
          label = "SWAP";
          content = {
            type = "swap";
          };
        };
      };
    };
  };
}
