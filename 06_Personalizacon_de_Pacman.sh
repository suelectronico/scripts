#!/bin/bash

# Editar /etc/pacman.conf
echo "Editando /etc/pacman.conf..."

# Sustituir #Color por Color
sudo sed -i 's/#Color/Color/' /etc/pacman.conf

# Sustituir #VerbosePkgList por VerbosePkgList
sudo sed -i 's/#VerbosePkgList/VerbosePkgList/' /etc/pacman.conf

# Sustituir #ParallelDownloads = 5 por ParallelDownloads = 10 y agregar ILoveCandy
sudo sed -i '/#ParallelDownloads = 5/c\ParallelDownloads = 10\nILoveCandy' /etc/pacman.conf

# Sustituir #Include = /etc/pacman.d/mirrorlist por Include = /etc/pacman.d/mirrorlist debajo de #[multilib]
sudo sed -i '/#\[multilib\]/!b;n;s/#Include = \/etc\/pacman.d\/mirrorlist/Include = \/etc\/pacman.d\/mirrorlist/' /etc/pacman.conf

echo "Edición completada exitosamente."
