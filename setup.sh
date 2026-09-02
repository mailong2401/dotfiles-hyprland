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

# Gửi tín hiệu giữ quyền sudo ngầm để không bị hỏi lại giữa chừng.
# FIX: dùng trap EXIT để chắc chắn tiến trình nền này bị dọn dẹp khi script
# kết thúc (dù thành công, lỗi hay bị ngắt), tránh để lại tiến trình mồ côi
# chạy vô hạn kiểm tra sudo.
(while true; do sudo -n true; sleep 60; kill -0 "$$" 2>/dev/null || exit; done) 2>/dev/null &
SUDO_KEEPALIVE_PID=$!
cleanup() {
  kill "$SUDO_KEEPALIVE_PID" 2>/dev/null || true
}
trap cleanup EXIT

# =========================================================
# TỰ ĐỘNG TẠO CÁC THƯ MỤC NGƯỜI DÙNG TIÊU CHUẨN
# =========================================================
log_info "Đang tiến hành tạo các thư mục cá nhân..."
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
# FIX: dùng rsync -a thay vì cp -rf để việc đồng bộ .config từ repo rõ ràng
# hơn (không xóa file khác không liên quan, nhưng ghi đè đúng theo nguồn).
log_info "Đang sao chép các tệp cấu hình..."
if [ -d "$SCRIPT_DIR/.config" ]; then
  if command -v rsync &>/dev/null; then
    rsync -a "$SCRIPT_DIR/.config/" "$HOME/.config/"
  else
    cp -rf "$SCRIPT_DIR/.config" "$HOME/"
  fi
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
  fcitx5-unikey python alsa-utils xdg-user-dirs rsync

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
# FIX: thêm "|| log_warn" cho toàn bộ lệnh, để nếu một gói build lỗi (rất hay
# gặp với gói -git), script không dừng luôn giữa chừng vì set -e.
log_info "Đang cài đặt các gói phần mềm từ AUR..."
yay -S --needed --noconfirm \
  quickshell-git sysstat papirus-icon-theme ttf-material-symbols-variable-git \
  otf-comicshanns-nerd cava qt6-5compat \
  || log_warn "Một số gói AUR cài thất bại, kiểm tra lại thủ công nếu cần."

# =========================================================
# TỰ ĐỘNG TẢI VÀ PHÂN LOẠI FONT CHỮ (tổng dung lượng ~500MB)
# =========================================================
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
# LƯU Ý: ttf-google-fonts-git tải TOÀN BỘ thư viện Google Fonts (rất nặng,
# build lâu, dễ lỗi/timeout). Bỏ comment dòng dưới nếu bạn chắc chắn muốn nó.
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
  sudo pacman -S --needed --noconfirm nerd-fonts
else
  log_warn "Không tìm thấy nhóm gói 'nerd-fonts' trong kho chính, thử cài qua AUR..."
  yay -S --needed --noconfirm nerd-fonts-complete || log_warn "Cài Nerd Fonts thất bại, bỏ qua."
fi

# Sao chép nguyên thư mục font kèm theo script (nếu có, đặt trong thư mục Fonts/)
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

# Cài đặt cấu hình Quickshell (cartoon-shell)
# FIX: ưu tiên COPY từ thư mục cartoon-shell đi kèm sẵn với script (giống cách
# .config/ và Pictures/ được copy ở đầu script) — không phụ thuộc mạng, không
# lo git clone bị đứt giữa chừng. Chỉ git clone từ GitHub khi không tìm thấy
# bản local kèm theo script. Sau khi copy/clone đều xác minh có shell.qml
# (entrypoint thật của repo) trước khi coi là thành công, và không để set -e
# làm sập cả script nếu bước này thất bại.
QUICKSHELL_DIR="$HOME/.config/quickshell/cartoon-shell"
QUICKSHELL_LOCAL_SRC="$SCRIPT_DIR/cartoon-shell"
QUICKSHELL_REPO="https://github.com/lesang2312/cartoon-shell"
QUICKSHELL_ENTRYPOINT="shell.qml"

install_cartoon_shell() {
  local backup=""

  if [ -d "$QUICKSHELL_DIR" ]; then
    backup="${QUICKSHELL_DIR}.bak_$(date +%Y%m%d_%H%M%S)"
    log_warn "Cấu hình Quickshell đã tồn tại, sao lưu sang: $backup"
    mv "$QUICKSHELL_DIR" "$backup"
  fi

  mkdir -p "$HOME/.config/quickshell"

  # --- Ưu tiên 1: copy từ thư mục local đi kèm script ---
  if [ -d "$QUICKSHELL_LOCAL_SRC" ]; then
    if [ ! -f "$QUICKSHELL_LOCAL_SRC/$QUICKSHELL_ENTRYPOINT" ]; then
      log_warn "Tìm thấy $QUICKSHELL_LOCAL_SRC nhưng thiếu $QUICKSHELL_ENTRYPOINT, có thể copy chưa đầy đủ. Sẽ thử git clone thay thế."
    else
      log_info "Đang copy cartoon-shell từ: $QUICKSHELL_LOCAL_SRC"
      if command -v rsync &>/dev/null; then
        mkdir -p "$QUICKSHELL_DIR"
        rsync -a "$QUICKSHELL_LOCAL_SRC/" "$QUICKSHELL_DIR/"
      else
        cp -r "$QUICKSHELL_LOCAL_SRC" "$QUICKSHELL_DIR"
      fi
      if [ -f "$QUICKSHELL_DIR/$QUICKSHELL_ENTRYPOINT" ]; then
        log_info "Copy cartoon-shell thành công và đã xác minh!"
        return 0
      fi
      log_warn "Copy xong nhưng vẫn thiếu $QUICKSHELL_ENTRYPOINT ở đích, coi như thất bại."
      rm -rf "$QUICKSHELL_DIR"
    fi
  else
    log_warn "Không tìm thấy $QUICKSHELL_LOCAL_SRC, sẽ tải qua git clone."
  fi

  # --- Ưu tiên 2: git clone từ GitHub, có retry ---
  local max_retries=3
  local attempt=1
  while [ "$attempt" -le "$max_retries" ]; do
    log_info "Đang tải cartoon-shell từ GitHub (lần $attempt/$max_retries)..."
    rm -rf "$QUICKSHELL_DIR"
    if git clone --depth 1 "$QUICKSHELL_REPO" "$QUICKSHELL_DIR" \
      && [ -f "$QUICKSHELL_DIR/$QUICKSHELL_ENTRYPOINT" ]; then
      log_info "Tải cartoon-shell thành công và đã xác minh!"
      return 0
    fi
    log_warn "Clone thất bại hoặc thiếu $QUICKSHELL_ENTRYPOINT."
    attempt=$((attempt + 1))
    [ "$attempt" -le "$max_retries" ] && { log_warn "Thử lại sau 3 giây..."; sleep 3; }
  done

  # Hết cách: dọn dẹp thư mục hỏng, khôi phục bản cũ nếu có, KHÔNG làm sập
  # toàn bộ script (để các bước bluetooth/âm thanh/fcitx5 vẫn chạy tiếp).
  log_error "Không thể cài cartoon-shell (cả copy local lẫn git clone đều thất bại)."
  rm -rf "$QUICKSHELL_DIR"
  if [ -n "$backup" ]; then
    log_warn "Khôi phục lại cấu hình Quickshell cũ từ: $backup"
    mv "$backup" "$QUICKSHELL_DIR"
  else
    log_warn "Không có bản cũ để khôi phục. Hyprland có thể không load được panel Quickshell."
    log_warn "Đặt thư mục cartoon-shell cạnh script tại: $QUICKSHELL_LOCAL_SRC, hoặc tự chạy: git clone $QUICKSHELL_REPO $QUICKSHELL_DIR"
  fi
  return 1
}

install_cartoon_shell || log_warn "Bỏ qua bước cartoon-shell, tiếp tục các bước còn lại của script."

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
systemctl --user enable --now pipewire.service pipewire-pulse.service wireplumber.service

log_info "Đang mở âm lượng tổng và unmute ALSA..."
sudo alsactl init 2>/dev/null || true
amixer sset Master unmute 2>/dev/null || true
amixer sset Master 80% 2>/dev/null || true

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
# FIX: dùng vòng lặp để hỏi lại khi nhập sai, thay vì exit 1 khiến script
# báo lỗi dù toàn bộ phần cài đặt đã chạy thành công.
while true; do
  read -rp "Bạn có muốn reboot ngay bây giờ không? (y/n): " answer
  case "$answer" in
  [Yy]*)
    log_info "Đang khởi động lại máy..."
    sudo reboot
    break
    ;;
  [Nn]*)
    log_info "Đã bỏ qua reboot. Bạn có thể tự gõ lệnh: sudo reboot sau khi sẵn sàng."
    break
    ;;
  *)
    log_error "Vui lòng nhập đúng ký tự y hoặc n."
    ;;
  esac
done

exit 0
