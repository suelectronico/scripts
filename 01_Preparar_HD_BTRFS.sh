#!/bin/bash

# Verificar si el usuario es root
if [ "$EUID" -ne 0 ]; then
  echo "Por favor, ejecute como root"
  exit
fi

# Verificar si se pasó un parámetro
if [ -z "$1" ]; then
  echo "Error: No se proporcionó el nombre del disco duro."
  lsblk
  exit 1
fi

DISK="$1"

# Crear tabla de particiones GPT
parted $DISK --script mklabel gpt

# Preguntar si el sistema tiene Windows instalado
read -p "¿El sistema tiene Windows instalado? (s/n): " WINDOWS_INSTALLED

if [ "$WINDOWS_INSTALLED" == "s" ]; then
  parted $DISK --script mkpart primary 1MiB 100%
  parted $DISK --script name 1 rootfs
  ROOT_PART="${DISK}1"

  # Mostrar las particiones y pedir al usuario que ingrese la partición de Windows
  lsblk
  read -p "Ingrese el nombre de la partición donde está instalado Windows (e.g., /dev/sda1): " WINDOWS_PARTITION
else
  parted $DISK --script mkpart primary 1MiB 301MiB
  parted $DISK --script name 1 boot
  parted $DISK --script set 1 boot on
  parted $DISK --script mkpart primary 301MiB 100%
  parted $DISK --script name 2 rootfs
  BOOT_PART="${DISK}1"
  ROOT_PART="${DISK}2"
fi

# Formatear las particiones
if [ "$WINDOWS_INSTALLED" != "s" ]; then
  mkfs.fat -F32 $BOOT_PART
fi
mkfs.btrfs -f $ROOT_PART

# Montar la partición root
mount $ROOT_PART /mnt

# Crear los subvolúmenes
btrfs su cr /mnt/@
btrfs su cr /mnt/@home
btrfs su cr /mnt/@box
btrfs su cr /mnt/@vm
if [ "$WINDOWS_INSTALLED" == "s" ]; then
  btrfs su cr /mnt/@windows
fi

# Desmontar la partición root
umount /mnt

# Montar los subvolúmenes con las opciones especificadas
mount -o noatime,ssd,space_cache=v2,compress=zstd,discard=async,subvol=@ $ROOT_PART /mnt
mkdir -p /mnt/{home,box,vm}
mount -o noatime,ssd,space_cache=v2,compress=zstd,discard=async,subvol=@home $ROOT_PART /mnt/home
mount -o noatime,ssd,space_cache=v2,compress=zstd,discard=async,subvol=@box $ROOT_PART /mnt/box
mount -o noatime,ssd,space_cache=v2,compress=zstd,discard=async,nodatacow,autodefrag,subvol=@vm $ROOT_PART /mnt/vm

# Montar la partición de arranque si se creó
if [ "$WINDOWS_INSTALLED" != "s" ]; then
  mkdir -p /mnt/boot/efi
  mount $BOOT_PART /mnt/boot/efi
fi

# Montar la partición de Windows si se especificó
if [ "$WINDOWS_INSTALLED" == "s" ]; then
  mkdir -p /mnt/windows
  mount $WINDOWS_PARTITION /mnt/windows
fi

echo "Proceso completado exitosamente."
