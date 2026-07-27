# Hyprland(Lua) Dotfiles

A complete Hyprland(Lua) configuration with Quickshell, custom themes, and essential tools for a beautiful Wayland desktop experience.

## Requirements

### Minimum Requirements

- **Distro**: Arch Linux (or Arch-based: Manjaro, EndeavourOS, CachyOS, etc.) or NixOS

### Dependencies

The setup script will automatically install:
- Base system utilities (`git`, `base-devel`)
- Wayland compositor (Hyprland Lua)
- All required packages listed below

## Installation

### For Arch Linux

Clone and run the setup script:

```bash
cd ~
git clone https://github.com/mailong2401/dotfiles-hyprland
cd dotfiles-hyprland
chmod +x setup.sh
./setup.sh
```


The script will:
1. Check sudo permissions
2. Backup your existing config (if any)
3. Copy new configuration files
4. Update your system
5. Install all required packages
6. Set up yay AUR helper (if not installed)
7. Install AUR packages
8. Clone Quickshell configuration
9. Ask if you want to reboot

### Manual Installation

If you prefer manual installation:

```bash
# Update system
sudo pacman -Syu

# Install packages
sudo pacman -S --needed hyprland kitty brightnessctl \
  wl-clipboard noto-fonts-cjk nautilus grim slurp \
  xdg-desktop-portal-hyprland hyprpaper jq bc qt6-multimedia

# Install yay
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
cd ..

# Install AUR packages
yay -S quickshell-git sysstat papirus-icon-theme otf-comicshanns-nerd cava ttf-material-symbols-variable-git

# Copy configs
cp -r .config ~/
cp -r Pictures ~/

# Clone Quickshell theme
git clone https://github.com/mailong2401/cartoon-shell.git ~/.config/quickshell/cartoon-shell
```

## Installed Packages

### Core Packages (pacman)

| Package | Description |
|---------|-------------|
| `hyprland` | Dynamic tiling Wayland compositor |
| `hyprpaper` | Wallpaper utility for Hyprland |
| `kitty` | GPU-accelerated terminal emulator |
| `brightnessctl` | Brightness control tool |
| `wl-clipboard` | Wayland clipboard utilities |
| `noto-fonts-cjk` | CJK fonts support |
| `thunar` | File manager |
| `thunar-archive-plugin` | Archive support for Thunar |
| `grim` | Screenshot tool for Wayland |
| `slurp` | Screen area selection tool |
| `xdg-desktop-portal-hyprland` | XDG Desktop Portal for Hyprland |
| `dunst` | Notification daemon |
| `jq` | JSON processor |
| `ttf-nerd-fonts-symbols` | Font Awesome |
| `qt6-multimedia` | Quickshell plugin |

### AUR Packages (yay)

| Package | Description |
|---------|-------------|
| `quickshell-git` | Modern shell interface |
| `sysstat` | System performance tools |
| `papirus-icon-theme` | Icon theme |
| `otf-comicshanns-nerd` | Nerd Font variant |
| `cava` | Audio visualizer |
| `ttf-material-symbols-variable-git` | Nerd Font variant |

### Additional Configuration

| Component | Source |
|-----------|--------|
| Quickshell Theme | [cartoon-shell](https://github.com/mailong2401/cartoon-shell.git) |

## Backup

Your old configuration is automatically backed up to:
```
~/.dotfiles_backup_YYYYMMDD_HHMMSS/
```

## Credits

- Hyprland: [https://hyprland.org](https://hyprland.org)
- Quickshell: [https://quickshell.outfoxxed.me](https://quickshell.outfoxxed.me)
- Cartoon Shell: [https://github.com/mailong2401/cartoon-shell](https://github.com/mailong2401/cartoon-shell)

## License

MIT License - Feel free to use and modify

## Support

For issues or questions, please open an issue on GitHub.

---

Made with ❤️ for the Hyprland community
