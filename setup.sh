#!/bin/bash

# =============================
#          SETUP SCRIPT
# =============================

set -e # Exit on error
set -u # Exit on undefined variable

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
  echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
  echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
  echo -e "${RED}[ERROR]${NC} $1"
}

# Get script directory
SCRIPT_DIR=$(dirname "$(realpath "$0")")
BACKUP_DIR="$HOME/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"

# Check sudo permissions
log_info "Checking sudo permissions..."
if ! sudo -v; then
  log_error "Sudo permissions required to run this script"
  exit 1
fi

# Backup existing config if present
log_info "Checking and backing up existing config..."
if [ -d "$HOME/.config/hypr" ] || [ -d "$HOME/.config/kitty" ]; then
  log_warn "Existing config detected, backing up to: $BACKUP_DIR"
  mkdir -p "$BACKUP_DIR"
  [ -d "$HOME/.config" ] && cp -r "$HOME/.config" "$BACKUP_DIR/" 2>/dev/null || true
  [ -d "$HOME/Pictures" ] && cp -r "$HOME/Pictures" "$BACKUP_DIR/" 2>/dev/null || true
  log_info "Backup completed"
fi

# Copy configuration files
log_info "Copying configuration files..."
if [ -d "$SCRIPT_DIR/.config" ]; then
  cp -rf "$SCRIPT_DIR/.config" "$HOME/"
  log_info "Copied .config"
else
  log_warn "Directory not found: $SCRIPT_DIR/.config"
fi

if [ -d "$SCRIPT_DIR/Pictures" ]; then
  cp -rf "$SCRIPT_DIR/Pictures" "$HOME/"
  log_info "Copied Pictures"
else
  log_warn "Directory not found: $SCRIPT_DIR/Pictures"
fi

# Update system
log_info "Updating system..."
sudo pacman -Syu --noconfirm

# Install required packages
log_info "Installing packages: Hyprland and related tools..."
sudo pacman -S --needed --noconfirm \
  base-devel \
  hyprland \
  kitty \
  brightnessctl \
  wl-clipboard \
  noto-fonts-cjk \
  nautilus \
  grim \
  slurp \
  xdg-desktop-portal-hyprland \
  jq \
  matugen \
  starship \
  fish \
  adw-gtk-theme \
  bc \
  ttf-nerd-fonts-symbols \
  qt6-multimedia \
  pipewire \
  pipewire-pulse \
  pipewire-alsa \
  pipewire-jack \
  wireplumber \
  pavucontrol \
  bluez \
  bluez-utils \
  blueman \
  fcitx5 \
  fcitx5-gtk \
  fcitx5-qt \
  fcitx5-configtool \
  fcitx5-unikey \
  python

# Check and install yay
if command -v yay &>/dev/null; then
  log_info "yay already installed, skipping..."
else
  log_info "Installing yay AUR helper..."

  # Create temporary directory
  TEMP_DIR=$(mktemp -d)
  cd "$TEMP_DIR"

  log_info "Cloning yay from AUR..."
  git clone https://aur.archlinux.org/yay.git

  cd yay
  log_info "Building and installing yay..."
  makepkg -si --noconfirm

  # Cleanup
  cd "$HOME"
  rm -rf "$TEMP_DIR"
  log_info "yay installed successfully"
fi

# Install AUR packages
log_info "Installing quickshell, icon theme, fonts from AUR..."
yay -S --needed --noconfirm \
  quickshell-git \
  sysstat \
  papirus-icon-theme \
  ttf-material-symbols-variable-git \
  otf-comicshanns-nerd \
  cava \
  qt6-5compat

# Install quickshell configuration
log_info "Installing quickshell configuration..."
QUICKSHELL_DIR="$HOME/.config/quickshell/cartoon-shell"
if [ -d "$QUICKSHELL_DIR" ]; then
  log_warn "Quickshell config already exists, updating..."
  cd "$QUICKSHELL_DIR"
  git pull || log_warn "Unable to update, skipping..."
  cd "$HOME"
else
  mkdir -p "$HOME/.config/quickshell"
  git clone https://github.com/mailong2401/cartoon-shell.git "$QUICKSHELL_DIR"
  log_info "Quickshell configuration cloned successfully"
fi

# =========================================================
# Auto-patch known QML bugs in cartoon-shell (idempotent)
# =========================================================
# 1) OpacitySlider bind "value: KittyOpacityService.displayOpacity" cùng lúc
#    cho phép kéo tay (onMoved) -> lần kéo đầu tiên phá huỷ binding vĩnh viễn,
#    khiến thanh trượt lệch khỏi giá trị opacity thật của kitty.
# 2) KittyOpacityStat.qml dùng "root.isVertical" để định vị popup nhưng
#    không tự khai báo property này, và StatusTraySectionHorizontal/Vertical
#    cũng không truyền xuống -> popup luôn neo sai hướng khi ở tray dọc.
log_info "Applying known quickshell QML fixes (kitty opacity slider + isVertical)..."

python3 - "$QUICKSHELL_DIR" <<'PYEOF'
import sys, glob, os

qs_dir = sys.argv[1]

def find_file(name):
    matches = glob.glob(os.path.join(qs_dir, "**", name), recursive=True)
    return matches[0] if matches else None

# ---- Fix 1 & 2: KittyOpacityStat.qml ----
f = find_file("KittyOpacityStat.qml")
if f:
    with open(f, "r", encoding="utf-8") as fh:
        content = fh.read()
    changed = False

    if "property bool isVertical" not in content:
        old_header = "Item {\n    id: root\n"
        new_header = "Item {\n    id: root\n\n    property bool isVertical: false\n"
        if old_header in content:
            content = content.replace(old_header, new_header, 1)
            changed = True

    old_slider = (
        "OpacitySlider {\n"
        "                    Layout.fillWidth: true\n"
        "                    from: KittyOpacityService.minOpacity * 100\n"
        "                    to: KittyOpacityService.maxOpacity * 100\n"
        "                    value: KittyOpacityService.displayOpacity\n"
        "                    onMoved: KittyOpacityService.setOpacity(value)\n"
        "                }"
    )
    new_slider = (
        "OpacitySlider {\n"
        "                    id: opacitySlider\n"
        "                    Layout.fillWidth: true\n"
        "                    from: KittyOpacityService.minOpacity * 100\n"
        "                    to: KittyOpacityService.maxOpacity * 100\n"
        "                    onMoved: KittyOpacityService.setOpacity(value)\n\n"
        "                    Binding {\n"
        "                        target: opacitySlider\n"
        "                        property: \"value\"\n"
        "                        value: KittyOpacityService.displayOpacity\n"
        "                        when: !opacitySlider.pressed\n"
        "                        restoreMode: Binding.RestoreBindingOrValue\n"
        "                    }\n"
        "                }"
    )
    if old_slider in content:
        content = content.replace(old_slider, new_slider, 1)
        changed = True

    if changed:
        with open(f, "w", encoding="utf-8") as fh:
            fh.write(content)
        print(f"[fix] patched {f}")
    else:
        print(f"[skip] {f} already up to date (or pattern not found)")
else:
    print("[warn] KittyOpacityStat.qml not found, skipping")

# ---- Fix 2b: truyền isVertical xuống KittyOpacityStat ----
for name in ("StatusTraySectionHorizontal.qml", "StatusTraySectionVertical.qml"):
    f = find_file(name)
    if not f:
        print(f"[warn] {name} not found, skipping")
        continue
    with open(f, "r", encoding="utf-8") as fh:
        content = fh.read()
    old = "KittyOpacityStat {\n            anchors.centerIn: parent\n        }"
    new = "KittyOpacityStat {\n            anchors.centerIn: parent\n            isVertical: root.isVertical\n        }"
    if old in content:
        content = content.replace(old, new, 1)
        with open(f, "w", encoding="utf-8") as fh:
            fh.write(content)
        print(f"[fix] patched {f}")
    else:
        print(f"[skip] {f} already up to date (or pattern not found)")
PYEOF

log_info "Quickshell QML fixes applied."

# Enable Bluetooth service
log_info "Enabling Bluetooth service..."
sudo systemctl enable --now bluetooth.service

# Enable audio services (user-level, PipeWire stack)
log_info "Enabling audio (PipeWire) services..."
systemctl --user enable --now pipewire.service pipewire-pulse.service wireplumber.service

# Configure fcitx5 input method environment variables
log_info "Configuring fcitx5 environment variables..."
mkdir -p "$HOME/.config/environment.d"
cat >"$HOME/.config/environment.d/fcitx5.conf" <<'EOF'
GTK_IM_MODULE=fcitx
QT_IM_MODULE=fcitx
XMODIFIERS=@im=fcitx
SDL_IM_MODULE=fcitx
GLFW_IM_MODULE=ibus
EOF

# Autostart fcitx5 on login
mkdir -p "$HOME/.config/autostart"
cat >"$HOME/.config/autostart/fcitx5.desktop" <<'EOF'
[Desktop Entry]
Type=Application
Name=Fcitx5
Exec=fcitx5 -d
NoDisplay=true
EOF
log_info "fcitx5 will start automatically on next login"

# Complete
log_info "========================================="
log_info "Installation completed successfully!"
log_info "========================================="
if [ -d "$BACKUP_DIR" ]; then
  log_info "Old configuration saved at: $BACKUP_DIR"
fi
log_info "Please reboot to complete the setup."

# Ask for reboot
read -p "Do you want to reboot now? (y/n): " answer

case "$answer" in
[Yy]*)
  log_info "Rebooting..."
  sudo reboot
  ;;
[Nn]*)
  log_info "Reboot skipped. You can reboot later with: sudo reboot"
  exit 0
  ;;
*)
  log_error "Please enter y or n."
  exit 1
  ;;
esac