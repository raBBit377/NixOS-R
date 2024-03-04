#!/bin/bash

# Змінні
disk="/dev/sda"
esp_size="5.4gb"
swap_size="50G"
btrfs_start="4.5GiB"

# Створення ESP (EFI System Partition)
parted "$disk" -- mklabel gpt
parted "$disk" mkpart esp fat32 0% "$esp_size"
parted "$disk" set 1 esp on
parted "$disk" set 1 boot on
mkfs.fat -F 32 -n UEFI "${disk}1"

# Створення Swap
parted "$disk" mkpart swap linux-swap "$esp_size" +"$swap_size"
mkswap -L SWAP "${disk}2"

# Створення BTRFS
parted "$disk" mkpart nixos btrfs "$btrfs_start" 100%
mkfs.btrfs -f -L NIXOS "${disk}3"

# BTRFS subvolumes
mount -t btrfs "${disk}3" /mnt
btrfs subvolume create /mnt/@root
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@nix
umount /mnt

# Монтування
mount -t btrfs -o noatime,compress=zstd,subvol=@root "${disk}3" /mnt
mkdir -p /mnt/{boot,nix,home}
mount -t btrfs -o noatime,compress=zstd,subvol=@home "${disk}3" /mnt/home
mount -t btrfs -o noatime,compress=zstd,subvol=@nix "${disk}3" /mnt/nix
mount -t vfat "${disk}1" /mnt/boot
swapon "${disk}2"

echo "Готово! Розділений диск та налаштовано файлові системи."




