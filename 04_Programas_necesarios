#!/bin/bash

if [ "$EUID" -ne 0 ]; then
  echo "Por favor, ejecuta este script como root."
  exit 1
fi

# Instalar paquetes
echo "Instalando paquetes dhcp, dhcpcd, networkmanager, iwd..."
sudo pacman -S --noconfirm dhcp dhcpcd networkmanager iwd

# Habilitar NetworkManager para que arranque con el sistema
echo "Habilitando NetworkManager para que arranque con el sistema..."
sudo systemctl enable NetworkManager
sudo systemctl start NetworkManager

# Instalar paquetes bluez y bluez-utils
echo "Instalando paquetes bluez y bluez-utils..."
sudo pacman -S --noconfirm bluez bluez-utils

# Habilitar el servicio bluetooth
echo "Habilitando el servicio Bluetooth..."
sudo systemctl enable bluetooth
sudo systemctl start bluetooth

# Instalar reflector
echo "Instalando reflector..."
sudo pacman -S --noconfirm reflector

# Obtener los 10 mirrors más rápidos
echo "Obteniendo los 10 mirrors más rápidos..."
sudo reflector --verbose --latest 10 --sort rate --save /etc/pacman.d/mirrorlist

# Preguntar si el CPU es Intel o AMD
echo "Seleccione su CPU:"
echo "1) Intel"
echo "2) AMD"
read -p "Ingrese el número correspondiente a su CPU (1 o 2): " cpu_choice

# Instalar el paquete correspondiente según el CPU
if [ "$cpu_choice" -eq 1 ]; then
    echo "Instalando el paquete intel-ucode..."
    sudo pacman -S --noconfirm intel-ucode
elif [ "$cpu_choice" -eq 2 ]; then
    echo "Instalando el paquete amd-ucode..."
    sudo pacman -S --noconfirm amd-ucode
else
    echo "Selección no válida. Por favor, ejecute el script nuevamente y elija 1 o 2."
    exit 1
fi

echo "Script completado exitosamente."
