#!/bin/bash

# =============================
#          SETUP SCRIPT
# =============================


sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &


# Cập nhật hệ thống trước khi cài đặt
echo "Đang cập nhật hệ thống..."
pacman -Syu --noconfirm

echo "Mở khóa wifi nếu bị block..."
rfkill unblock wifi

# Lấy tên thiết bị wifi (wlan0 hoặc tương tự)
WIFI_DEV=$(ip link | grep -E 'wl|wifi' | awk -F: '{print $2}' | tr -d ' ' | head -n1)

if [ -z "$WIFI_DEV" ]; then
    echo "⚠️ Không tìm thấy thiết bị wifi nào!"
    exit 1
fi

echo "Bật thiết bị wifi: $WIFI_DEV"
ip link set "$WIFI_DEV" up

echo "Hoàn tất."


# Cài đặt các gói cần thiết
echo "Cài đặt các gói: Hyprland, Neovim, Foot, Wofi, Waybar, Zsh..."
pacman -S --needed --noconfirm hyprland neovim foot wofi waybar zsh lsd ttf-jetbrains-mono-nerd brightnessctl

# Tự động trả lời cho qt6-multimedia-backend (mặc định 1)
# và phonon-qt6-backend (muốn chọn 2)
# Dùng 'printf' gửi lựa chọn lần lượt cho pacman

printf "1\n2\n" | pacman -S --needed dolphin


# Clone và cài đặt `yay` nếu chưa tồn tại
if [ ! -d "yay" ]; then
    echo "Cloning yay..."
    git clone https://aur.archlinux.org/yay.git
fi

cd yay || exit
echo "Đang build và cài đặt yay..."
makepkg -si --noconfirm
cd ..

# Cấu hình auto-login cho TTY1
echo "Cấu hình auto-login cho TTY1..."
mkdir -p /etc/systemd/system/getty@tty1.service.d/
echo -e "[Service]\nExecStart=\nExecStart=-/sbin/agetty --autologin long --noclear %I \$TERM" | tee /etc/systemd/system/getty@tty1.service.d/override.conf > /dev/null

# Cấu hình tự động vào Hyprland khi login vào TTY1
echo "Thêm cấu hình tự động khởi động Hyprland..."
if ! grep -q "exec hyprland" ~/.bash_profile; then
    echo 'if [[ -z $DISPLAY ]] && [[ $(tty) == /dev/tty1 ]]; then exec hyprland; fi' >> ~/.bash_profile
fi

# Cài đặt Oh My Zsh không cần tương tác
echo "Cài đặt Oh My Zsh..."
yes n | sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"


# Cài đặt các plugin Zsh
echo "Cài đặt Zsh Plugins..."
if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
fi

if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
fi


cp -rf .zshrc ~/
cp -rf .config ~/ 
cp -rf Pictures ~/

# Cài đặt Google Chrome qua yay
echo "Cài đặt Google Chrome..."
yay -S --noconfirm google-chrome

# 🛠️ Cleanup sau khi cài đặt
echo "Dọn dẹp sau khi cài đặt..."
rm -rf yay

# ✅ Hoàn thành
echo "Quá trình cài đặt hoàn tất! Khởi động lại máy để hoàn tất cấu hình."

