sudo su
nix-shell -p btrfs-progs

parted /dev/sda -- mklabel gpt

## MARKING

# BOOT
parted /dev/sda mkpart esp fat32 0% 5.4gb
parted /dev/sda set 1 esp on
parted /dev/sda set 1 boot on
mkfs.fat -F 32 -n UEFI /dev/sda1

# SWAP
parted /dev/sda mkpart swap linux-swap 512mb 44.5gb
mkswap -L SWAP /dev/sda2

# BTRFS
parted /dev/sda mkpart nixos btrfs 4.5GiB 100%
mkfs.btrfs -f -L NIXOS /dev/sda3

## BTRFS subvolumes
mount -t btrfs /dev/sda3 /mnt
btrfs subvolume create /mnt/@root
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@nix
umount /mnt

## MOUNT
mount -t btrfs -o noatime,ssd,compress=zstd:3,subvol=@root /dev/sda3 /mnt
mkdir -p /mnt/{boot,nix,home}
mount -t btrfs -o noatime,ssd,compress=zstd:3,subvol=@home /dev/sda3 /mnt/home
mount -t btrfs -o noatime,ssd,compress=zstd:3,subvol=@nix /dev/sda3 /mnt/nix
mount -t vfat /dev/sda1 /mnt/boot
swapon /dev/sda2

nixos-generate-config --root /mnt

nixos-install
