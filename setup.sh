#!/bin/bash

# =============================
#          SETUP SCRIPT
# =============================

# Lấy thư mục chứa script
SCRIPT_DIR=$(dirname "$(realpath "$0")")

# Sao chép các file cấu hình
echo "Đang sao chép file cấu hình cá nhân..."
cp -rf "$SCRIPT_DIR/.config" $HOME/
cp -rf "$SCRIPT_DIR/Pictures" $HOME/
echo "Hoàn tất sao chép."

cd $HOME

# Cập nhật hệ thống trước khi cài đặt
echo "Đang cập nhật hệ thống..."
sudo pacman -Syu --noconfirm

echo "Mở khóa wifi nếu bị block..."
rfkill unblock wifi

# Lấy tên thiết bị wifi (wlan0 hoặc tương tự)
WIFI_DEV=$(ip link | grep -E 'wl|wifi' | awk -F: '{print $2}' | tr -d ' ' | head -n1)

if [ -z "$WIFI_DEV" ]; then
  echo "⚠️ Không tìm thấy thiết bị wifi nào!"
  exit 1
fi

echo "Bật thiết bị wifi: $WIFI_DEV"
sudo ip link set "$WIFI_DEV" up

echo "Hoàn tất."

# Cài đặt các gói cần thiết
echo "Cài đặt các gói: Hyprland, Neovim, Foot, Wofi, Waybar, Zsh..."
sudo pacman -S --needed --noconfirm hyprland neovim kitty wofi waybar zsh lsd ttf-jetbrains-mono-nerd brightnessctl swaybg iwd wl-clipboard otf-comicshanns-nerd python-pip npm nodejs ruby noto-fonts-cjk fcitx5 fcitx5-configtool fcitx5-gtk fcitx5-qt fcitx5-unikey fcitx5-hangul thunar thunar-archive-plugin nvidia nvidia-utils nvidia-settings linux-headers grim slurp xdg-desktop-portal-hyprland

sudo systemctl enable iwd.service
sudo systemctl start iwd.service

echo "Tạo file blacklist nouveau..."
sudo bash -c 'cat > /etc/modprobe.d/blacklist-nouveau.conf << EOF
blacklist nouveau
options nouveau modeset=0
EOF'

echo "Tạo lại initramfs..."
sudo mkinitcpio -P

# Clone và cài đặt `yay` nếu chưa tồn tại
if [ ! -d "yay" ]; then
  echo "Cloning yay..."
  git clone https://aur.archlinux.org/yay.git
fi

cd yay || exit
echo "Đang build và cài đặt yay..."
makepkg -si --noconfirm
cd ..

# # Cấu hình auto-login cho TTY1
# echo "Cấu hình auto-login cho TTY1..."
# sudo mkdir -p /etc/systemd/system/getty@tty1.service.d/
# echo -e "[Service]\nExecStart=\nExecStart=-/sbin/agetty --autologin long --noclear %I \$TERM" | sudo tee /etc/systemd/system/getty@tty1.service.d/override.conf >/dev/null

# Cấu hình tự động vào Hyprland khi login vào TTY1
echo "Thêm cấu hình tự động khởi động Hyprland..."
if ! grep -q "exec hyprland" ~/.bash_profile; then
  echo 'if [[ -z $DISPLAY ]] && [[ $(tty) == /dev/tty1 ]]; then exec hyprland; fi' >>~/.bash_profile
fi

# Cài đặt Oh My Zsh không cần tương tác
echo "Cài đặt Oh My Zsh..."
RUNZSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Cài đặt các plugin Zsh
echo "Cài đặt Zsh Plugins..."
if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions" ]; then
  git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
fi

if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" ]; then
  git clone https://github.com/zsh-users/zsh-syntax-highlighting ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
fi

cp -rf "$SCRIPT_DIR/.zshrc" $HOME/

# Cai config neovim
sudo npm install -g neovim
gem install neovim
pip install --user neovim --break-system-packages

# Cài đặt Google Chrome qua yay
echo "Cài đặt Google Chrome..."
yay -S --noconfirm google-chrome

# 🛠️ Cleanup sau khi cài đặt
echo "Dọn dẹp sau khi cài đặt..."
rm -rf yay

# ✅ Hoàn thành
echo "Quá trình cài đặt hoàn tất! Khởi động lại máy để hoàn tất cấu hình."
read -p "Bạn có muốn reboot không? (y/n): " answer

case "$answer" in
[Yy]*)
  echo "Đang reboot..."
  sudo reboot
  ;;
[Nn]*)
  echo "Hủy reboot."
  exit 0
  ;;
*)
  echo "Vui lòng nhập y hoặc n."
  exit 1
  ;;
esac
