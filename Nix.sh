sudo su
nix-shell -p btrfs-progs

parted /dev/sda -- mklabel gpt

## MARKING

# BOOT
parted /dev/sdX mkpart esp fat32 0% 5.4gb
parted /dev/sdX set 1 esp on
parted /dev/sdX set 1 boot on
mkfs.fat -F 32 -n UEFI /dev/sdXY

# SWAP
parted /dev/sdX mkpart swap linux-swap 512mb 4.5gb
mkswap -L SWAP /dev/sdXW

# BTRFS
parted /dev/sdX mkpart nixos btrfs 4.5GiB 100%
mkfs.btrfs -f -L NIXOS /dev/sdXZ

## BTRFS subvolumes
mount -t btrfs /dev/sdXZ /mnt
btrfs subvolume create /mnt/@root
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@nix
umount /mnt

## MOUNT
mount -t btrfs -o noatime,compress=zstd,subvol=@root /dev/sdXZ /mnt
mkdir -p /mnt/{boot,nix,home}
mount -t btrfs -o noatime,compress=zstd,subvol=@home /dev/sdXZ /mnt/home
mount -t btrfs -o noatime,compress=zstd,subvol=@nix /dev/sdXZ /mnt/nix
mount -t vfat /dev/sda1 /mnt/boot
swapon /dev/sdXW
