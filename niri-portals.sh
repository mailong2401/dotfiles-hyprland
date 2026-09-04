#!/bin/bash
# =============================================================
#   CÀI XDG-DESKTOP-PORTAL CHO NIRI + SLURP
# =============================================================
set -e
set -u

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info()  { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

if ! command -v pacman &>/dev/null; then
  log_error "Script này chỉ hỗ trợ Arch Linux (pacman). Dừng lại."
  exit 1
fi

log_info "Đang kiểm tra quyền sudo..."
if ! sudo -v; then
  log_error "Yêu cầu quyền sudo để chạy script này"
  exit 1
fi

# =============================================================
# 1. CÀI XDG-DESKTOP-PORTAL + BACKEND CHO NIRI
# =============================================================
log_info "Đang cài xdg-desktop-portal và các backend cho niri..."
sudo pacman -S --needed --noconfirm \
  xdg-desktop-portal \
  xdg-desktop-portal-gnome \
  xdg-desktop-portal-gtk

# =============================================================
# 2. CÀI SLURP + SWAYBG (đặt hình nền)
# =============================================================
log_info "Đang cài slurp và swaybg..."
sudo pacman -S --needed --noconfirm slurp swaybg

# =============================================================
# 3. RESTART LẠI CÁC PORTAL SERVICE
# =============================================================
log_info "Đang khởi động lại các portal service để áp dụng cấu hình..."
systemctl --user restart xdg-desktop-portal-gtk.service xdg-desktop-portal-gnome.service xdg-desktop-portal.service 2>/dev/null \
  || log_warn "Một vài service chưa chạy (bình thường nếu chưa đăng nhập session niri), sẽ tự khởi động khi vào niri."

log_info "========================================="
log_info "Hoàn tất! Đăng xuất và đăng nhập lại niri để áp dụng đầy đủ."
log_info "========================================="
