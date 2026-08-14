#!/bin/bash

# =============================
#          SETUP SCRIPT
# =============================

set -e # Thoát nếu gặp lỗi
set -u # Thoát nếu biến chưa định nghĩa

# Màu sắc đầu ra
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # Không màu

log_info() {
  echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
  echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
  echo -e "${RED}[ERROR]${NC} $1"
}

# Đảm bảo thiết lập biến môi trường chạy đúng session user phòng lỗi D-Bus
export XDG_RUNTIME_DIR="/run/user/$(id -u)"
export DBUS_SESSION_BUS_ADDRESS="unix:path=$XDG_RUNTIME_DIR/bus"

SCRIPT_DIR=$(dirname "$(realpath "$0")")
BACKUP_DIR="$HOME/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"

# Kiểm tra quyền sudo ban đầu
log_info "Đang kiểm tra quyền sudo..."
if ! sudo -v; then
  log_error "Yêu cầu quyền sudo để chạy script này"
  exit 1
fi

# Gửi tín hiệu giữ quyền sudo ngầm để không bị hỏi lại giữa chừng
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# =========================================================
# TỰ ĐỘNG TẠO CÁC THƯ MỤC NGƯỜI DÙNG TIÊU CHUẨN
# =========================================================
log_info "Đang tiến hành tạo các thư mục cá nhân cá nhân..."
mkdir -p "$HOME/Music" "$HOME/Documents" "$HOME/Downloads" "$HOME/Pictures" "$HOME/Videos" "$HOME/Desktop" "$HOME/Public" "$HOME/Templates"
log_info "Đã tạo xong các thư mục cá nhân."

# Sao lưu cấu hình cũ nếu có
log_info "Đang kiểm tra và sao lưu cấu hình cũ..."
if [ -d "$HOME/.config/hypr" ] || [ -d "$HOME/.config/kitty" ]; then
  log_warn "Phát hiện cấu hình cũ, đang sao lưu vào: $BACKUP_DIR"
  mkdir -p "$BACKUP_DIR"
  [ -d "$HOME/.config" ] && cp -r "$HOME/.config" "$BACKUP_DIR/" 2>/dev/null || true
  [ -d "$HOME/Pictures" ] && cp -r "$HOME/Pictures" "$BACKUP_DIR/" 2>/dev/null || true
  log_info "Sao lưu hoàn tất"
fi

# Sao chép các tệp cấu hình kèm theo script (nếu có)
log_info "Đang sao chép các tệp cấu hình..."
if [ -d "$SCRIPT_DIR/.config" ]; then
  cp -rf "$SCRIPT_DIR/.config" "$HOME/"
  log_info "Đã sao chép .config"
else
  log_warn "Không tìm thấy thư mục: $SCRIPT_DIR/.config"
fi

if [ -d "$SCRIPT_DIR/Pictures" ]; then
  cp -rf "$SCRIPT_DIR/Pictures" "$HOME/"
  log_info "Đã sao chép Pictures"
else
  log_warn "Không tìm thấy thư mục: $SCRIPT_DIR/Pictures"
fi

# Cập nhật hệ thống
log_info "Đang cập nhật hệ thống..."
sudo pacman -Syu --noconfirm

# Cài đặt các gói phần mềm bắt buộc từ kho chính Arch
log_info "Đang cài đặt các gói phần mềm hệ thống..."
sudo pacman -S --needed --noconfirm \
  base-devel hyprland kitty brightnessctl wl-clipboard noto-fonts-cjk \
  nautilus grim slurp xdg-desktop-portal-hyprland jq matugen starship \
  fish adw-gtk-theme bc ttf-nerd-fonts-symbols qt6-multimedia pipewire \
  pipewire-pulse pipewire-alsa pipewire-jack wireplumber pavucontrol \
  bluez bluez-utils blueman fcitx5 fcitx5-gtk fcitx5-qt fcitx5-configtool \
  fcitx5-unikey python alsa-utils xdg-user-dirs

# Cập nhật cấu hình thư mục hệ thống xdg
xdg-user-dirs-update || true

# Kiểm tra và cài đặt yay AUR helper
if command -v yay &>/dev/null; then
  log_info "yay đã được cài đặt, bỏ qua..."
else
  log_info "Đang cài đặt yay AUR helper..."
  TEMP_DIR=$(mktemp -d)
  cd "$TEMP_DIR"
  # Clone đúng kho Git nguồn của yay (trước đây clone nhầm archlinux.org khiến script thoát sớm do set -e)
  git clone https://aur.archlinux.org/yay.git
  cd yay
  makepkg -si --noconfirm
  cd "$HOME"
  rm -rf "$TEMP_DIR"
  log_info "Cài đặt yay thành công"
fi

# Cài đặt các gói phần mềm từ AUR
log_info "Đang cài đặt các gói phần mềm từ AUR..."
# Chạy trực tiếp mà không mượn môi trường root nguy hiểm
yay -S --needed --noconfirm \
  quickshell-git sysstat papirus-icon-theme ttf-material-symbols-variable-git \
  otf-comicshanns-nerd cava qt6-5compat

# =========================================================
# TỰ ĐỘNG TẢI VÀ PHÂN LOẠI FONT CHỮ (tổng dung lượng ~500MB)
# =========================================================
# Mỗi gói pacman/AUR bên dưới sẽ tự tạo thư mục riêng trong /usr/share/fonts
# (vd: noto-cjk, liberation, Adwaita, encodings...) giống cấu trúc chuẩn của hệ thống.
log_info "Đang cài đặt các gói font cơ bản từ kho chính Arch..."
sudo pacman -S --needed --noconfirm \
  noto-fonts noto-fonts-extra noto-fonts-emoji noto-fonts-cjk \
  ttf-liberation ttf-dejavu ttf-droid gnu-free-fonts \
  adobe-source-sans-fonts adobe-source-serif-fonts adobe-source-code-pro-fonts \
  ttf-jetbrains-mono ttf-fira-code ttf-fira-sans ttf-roboto ttf-roboto-mono \
  ttf-ubuntu-font-family ttf-opensans cantarell-fonts ttf-carlito ttf-caladea \
  ttf-hack ttf-inconsolata ttf-anonymous-pro \
  ttf-cascadia-code ttf-cascadia-mono ttf-ibm-plex \
  ttf-linux-libertine ttf-gentium-basic \
  encodings

# --- Font Chữ Viết Tay, Cổ Điển, Display từ AUR ---
log_info "Đang cài đặt font đẹp từ AUR (viết tay, cổ điển, display)..."
yay -S --needed --noconfirm \
  ttf-google-fonts-git \
  ttf-ms-fonts \
  ttf-ancient-fonts \
  ttf-unifont \
  otf-eb-garamond \
  ttf-lato \
  ttf-merriweather \
  ttf-oswald \
  ttf-raleway \
  ttf-cormorant \
  ttf-crimson-pro \
  ttf-playfair-display || log_warn "Một số font AUR cài thất bại, bỏ qua và tiếp tục..."

log_info "Đang cài đặt trọn bộ Nerd Fonts (dung lượng lớn, có thể mất vài phút)..."
if sudo pacman -Sg nerd-fonts &>/dev/null; then
  # Nhóm gói 'nerd-fonts' trong kho chính Arch chứa hàng chục font đã patch icon
  sudo pacman -S --needed --noconfirm nerd-fonts
else
  log_warn "Không tìm thấy nhóm gói 'nerd-fonts' trong kho chính, thử cài qua AUR..."
  yay -S --needed --noconfirm nerd-fonts-complete || log_warn "Cài Nerd Fonts thất bại, bỏ qua."
fi

# Sao chép nguyên thư mục font kèm theo script (nếu có, đặt trong thư mục Fonts/)
# vào /usr/share/fonts/NerdFonts, giữ nguyên cấu trúc, không phân loại
MANUAL_FONTS_DIR="$SCRIPT_DIR/Fonts"
if [ -d "$MANUAL_FONTS_DIR" ]; then
  log_info "Đang sao chép thư mục font thủ công từ: $MANUAL_FONTS_DIR"
  sudo mkdir -p /usr/share/fonts/NerdFonts
  sudo cp -r "$MANUAL_FONTS_DIR"/. /usr/share/fonts/NerdFonts/
  log_info "Đã sao chép xong font thủ công vào /usr/share/fonts/NerdFonts"
else
  log_warn "Không tìm thấy thư mục font thủ công: $MANUAL_FONTS_DIR (bỏ qua bước này)"
fi

log_info "Đang cập nhật cache font hệ thống (fc-cache)..."
sudo fc-cache -f
log_info "Đã cài đặt và phân loại font xong. Kiểm tra tại /usr/share/fonts"

# Cài đặt cấu hình Quickshell từ kho lesang2312/cartoon-shell
log_info "Đang cài đặt cấu hình cartoon-shell từ lesang2312..."
QUICKSHELL_DIR="$HOME/.config/quickshell/cartoon-shell"

if [ -d "$QUICKSHELL_DIR" ]; then
  log_warn "Cấu hình Quickshell đã tồn tại, đang tiến hành dọn dẹp để cài mới..."
  rm -rf "$QUICKSHELL_DIR"
fi

mkdir -p "$HOME/.config/quickshell"
git clone https://github.com/lesang2312/cartoon-shell "$QUICKSHELL_DIR"
log_info "Tải cấu hình từ lesang2312 thành công!"

# =========================================================
# TỰ ĐỘNG BẬT BLUETOOTH KHI KHỞI ĐỘNG HỆ THỐNG
# =========================================================
log_info "Đang cấu hình tự động bật Bluetooth..."
sudo systemctl enable bluetooth.service

sudo mkdir -p /etc/bluetooth
if [ -f /etc/bluetooth/main.conf ]; then
  sudo sed -i 's/#\s*AutoEnable\s*=\s*false/AutoEnable=true/g' /etc/bluetooth/main.conf
  sudo sed -i 's/#\s*AutoEnable\s*=\s*true/AutoEnable=true/g' /etc/bluetooth/main.conf
  sudo sed -i 's/AutoEnable\s*=\s*false/AutoEnable=true/g' /etc/bluetooth/main.conf
else
  echo -e "[General]\nAutoEnable=true" | sudo tee /etc/bluetooth/main.conf > /dev/null
fi
sudo systemctl restart bluetooth.service

# =========================================================
# TỰ ĐỘNG KÍCH HOẠT VÀ MỞ ÂM THANH (PIPEWIRE & ALSA)
# =========================================================
log_info "Đang cấu hình tự động kích hoạt và bật âm thanh..."
# Sử dụng đúng DBUS_SESSION để bật dịch vụ dạng --user sạch sẽ
systemctl --user enable --now pipewire.service pipewire-pulse.service wireplumber.service

log_info "Đang mở âm lượng tổng và unmute ALSA..."
sudo alsactl init 2>/dev/null || true
amixer sset Master unmute 2>/dev/null || true
amixer sset Master 80% 2>/dev/null || true

# Unmute và chỉnh âm lượng ở tầng PipeWire/WirePlumber (đây mới là tầng thực sự
# điều khiển output khi dùng pipewire, amixer/alsactl chỉ chỉnh tầng ALSA thấp
# và có thể không phản ánh đúng sink đang active)
if command -v wpctl &>/dev/null; then
  log_info "Đang mở âm lượng tổng và unmute qua WirePlumber (wpctl)..."
  wpctl set-mute @DEFAULT_AUDIO_SINK@ 0 2>/dev/null || true
  wpctl set-volume @DEFAULT_AUDIO_SINK@ 80% 2>/dev/null || true
else
  log_warn "Không tìm thấy wpctl, bỏ qua bước chỉnh âm lượng PipeWire."
fi

# Cấu hình biến môi trường cho bộ gõ fcitx5
log_info "Đang cấu hình môi trường fcitx5..."
mkdir -p "$HOME/.config/environment.d"
cat >"$HOME/.config/environment.d/fcitx5.conf" <<'EOF'
GTK_IM_MODULE=fcitx
QT_IM_MODULE=fcitx
XMODIFIERS=@im=fcitx
SDL_IM_MODULE=fcitx
GLFW_IM_MODULE=ibus
EOF

# Tự động khởi chạy fcitx5 khi đăng nhập máy
mkdir -p "$HOME/.config/autostart"
cat >"$HOME/.config/autostart/fcitx5.desktop" <<'EOF'
[Desktop Entry]
Type=Application
Name=Fcitx5
Exec=fcitx5 -d
NoDisplay=true
EOF
log_info "fcitx5 đã được thêm vào danh sách tự động chạy"

# Hoàn tất
log_info "========================================="
log_info "Cài đặt hoàn tất thành công!"
log_info "========================================="
if [ -d "$BACKUP_DIR" ]; then
  log_info "Bản sao lưu cấu hình cũ: $BACKUP_DIR"
fi
log_info "Hệ thống cần khởi động lại để áp dụng cài đặt mới."

# Hỏi khởi động lại
read -p "Bạn có muốn reboot ngay bây giờ không? (y/n): " answer

case "$answer" in
[Yy]*)
  log_info "Đang khởi động lại máy..."
  sudo reboot
  ;;
[Nn]*)
  log_info "Đã bỏ qua reboot. Bạn có thể tự gõ lệnh: sudo reboot sau khi sẵn sàng."
  exit 0
  ;;
*)
  log_error "Vui lòng nhập đúng ký tự y hoặc n."
  exit 1
  ;;
esac