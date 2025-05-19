#!/bin/bash

# file setup.sh

# Cập nhật hệ thống trước khi cài đặt
sudo pacman -Syu --noconfirm

# Cài đặt các gói cần thiết
sudo pacman -S --needed --noconfirm hyprland neovim kitty wofi waybar

# Clone và cài đặt yay
if [ ! -d "yay" ]; then
    git clone https://aur.archlinux.org/yay.git
fi

cd yay || exit
makepkg -si --noconfirm

