#!/bin/bash

# Виконання команд по черзі

sudo su

# Встановлення необхідного пакету
nix-shell -p btrfs-progs

# Створення розділів на диску
parted /dev/sda -- mklabel gpt
parted /dev/sda mkpart esp fat32 0% 5.4gb
parted /dev/sda set 1 esp on
parted /dev/sda set 1 boot on
parted /dev/sda mkpart swap linux-swap 512mb 4.5gb
parted /dev/sda mkpart nixos btrfs 4.5GiB 100%

# Форматування файлових систем
mkfs.fat -F 32 -n UEFI /dev/sda1
mkswap -L SWAP /dev/sda2
mkfs.btrfs -f -L NIXOS /dev/sda3

# BTRFS subvolumes
mount -t btrfs /dev/sda3 /mnt
btrfs subvolume create /mnt/@root
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@nix
umount /mnt

# Монтування файлових систем
mount -t btrfs -o noatime,compress=zstd,subvol=@root /dev/sda3 /mnt
mkdir -p /mnt/{boot,nix,home}
mount -t btrfs -o noatime,compress=zstd,subvol=@home /dev/sda3 /mnt/home
mount -t btrfs -o noatime,compress=zstd,subvol=@nix /dev/sda3 /mnt/nix
mount -t vfat /dev/sda1 /mnt/boot
swapon /dev/sda2

echo "Всі команди виконані послідовно."


