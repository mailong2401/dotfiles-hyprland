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
  qt6-multimedia

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
