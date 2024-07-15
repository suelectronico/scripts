#!/bin/bash

# Instalar paquetes grub y efibootmgr
echo "Instalando paquetes grub y efibootmgr..."
sudo pacman -S --noconfirm grub efibootmgr

# Ejecutar comandos grub-install
echo "Ejecutando grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=Arch..."
sudo grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=Arch

echo "Ejecutando grub-install --target=x86_64-efi --efi-directory=/boot/efi --removable..."
sudo grub-install --target=x86_64-efi --efi-directory=/boot/efi --removable

# Editar el archivo /etc/default/grub
echo "Editando /etc/default/grub..."
sudo sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet"/GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3"/' /etc/default/grub

# Generar la configuración de GRUB
echo "Generando la configuración de GRUB..."
sudo grub-mkconfig -o /boot/grub/grub.cfg

echo "Script completado exitosamente."
