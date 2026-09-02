# Hyprland(Lua) Dotfiles

A complete Hyprland(Lua) configuration with Quickshell, custom themes, and essential tools for a beautiful Wayland desktop experience.

> [!NOTE]
> This is an updated and feature-extended version of the original "dotfiles-hyprland" project created and owned by **Mai Duong Long** (mailong2401).

## 🚀 New Features Added in This Version

Compared to the original repository, this build includes the following pre-configured additions:

* **Custom Kitty Opacity Slider**: Easily adjust the terminal's background transparency on-the-fly using a convenient slider.
* **Vietnamese Input Method**: Pre-configured `fcitx5` for seamless Vietnamese typing.
* **Bluetooth Support**: Native bluetooth modules enabled out-of-the-box.
* **Audio Control**: Fully integrated speaker and volume control modules.
* **Additional System Updates**: Includes performance optimizations, enhanced visual transitions, and key stability fixes for the core modules.


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
git clone https://github.com/lesang2312/dotfiles-hyprland
cd dotfiles-hyprland
chmod +x setup.sh
./setup.sh
gsettings set org.gnome.desktop.interface icon-theme "Papirus-Dark"
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

## Installed Packages

### Core Packages (pacman)

| Package | Description |
|---------|-------------|
| `base-devel` | Essential tools for building and compiling packages |
| `hyprland` | Dynamic tiling Wayland compositor |
| `kitty` | GPU-accelerated terminal emulator |
| `brightnessctl` | Brightness control tool |
| `wl-clipboard` | Wayland clipboard utilities |
| `noto-fonts-cjk` | Google Noto CJK fonts support |
| `nautilus` | GNOME file manager (replaces Thunar) |
| `grim` | Screenshot tool for Wayland |
| `slurp` | Screen area selection tool |
| `xdg-desktop-portal-hyprland` | XDG Desktop Portal backend for Hyprland |
| `jq` | Command-line JSON processor |
| `matugen` | Material You color palette generator |
| `starship` | Customizable cross-shell prompt |
| `fish` | User-friendly command-line shell |
| `adw-gtk-theme` | Adwaita GTK theme for modern application styling |
| `bc` | Arbitrary precision calculator language |
| `ttf-nerd-fonts-symbols` | High-quality icon and symbol fonts |
| `qt6-multimedia` | Qt6 Multimedia API support for Quickshell plugins |
| `pipewire` | Low-latency audio and video server |
| `pipewire-pulse` | PulseAudio replacement layer for PipeWire |
| `pipewire-alsa` | ALSA support for PipeWire |
| `pipewire-jack` | JACK audio server compatibility layer |
| `wireplumber` | Modular session and policy manager for PipeWire |
| `pavucontrol` | PulseAudio volume control GUI |
| `bluez` | Linux Bluetooth protocol stack |
| `bluez-utils` | Development and debugging utilities for Bluetooth |
| `blueman` | Full-featured Bluetooth manager GUI |
| `fcitx5` | Next-generation input method framework |
| `fcitx5-gtk` | GTK IM module for Fcitx5 |
| `fcitx5-qt` | Qt IM module for Fcitx5 |
| `fcitx5-configtool` | Graphical configuration tool for Fcitx5 |
| `fcitx5-unikey` | Vietnamese Unikey input method engine for Fcitx5 |

### AUR Packages (yay)

| Package | Description |
|---------|-------------|
| `quickshell-git` | Modern shell interface framework based on Qt/QML |
| `sysstat` | System performance monitoring tools (used for bar widgets) |
| `papirus-icon-theme` | Pixel-perfect icon theme for Linux |
| `otf-comicshanns-nerd` | Comic Shanns font patched with Nerd Font icons |
| `cava` | Console-based Audio Visualizer |
| `ttf-material-symbols-variable-git` | Google's Material Symbols font for modern UI icons |
| `qt6-5compat` | Qt 6 module containing compatibility APIs with Qt 5 |


### Additional Configuration

| Component | Source |
|-----------|--------|
| Quickshell Theme | [cartoon-shell](https://github.com/lesang2312/cartoon-shell.git) |

## Backup

Your old configuration is automatically backed up to:
```
~/.dotfiles_backup_YYYYMMDD_HHMMSS/
```

## ⌨️ Keybindings Customization

You can easily modify, add, or change all system shortcuts, workspace management hotkeys, and window control rules by editing the Lua configuration file.

### Custom Keybindings File Path:
```bash
~/.config/hypr/config/keybindings.lua
```

### How to Change Keybindings:
* **Step 1**: Open your Terminal or your preferred text editor (e.g., VS Code, VSCodium, or Nano).
* **Step 2**: Open the configuration file using the absolute path:
  ```bash
  nano ~/.config/hypr/config/keybindings.lua
  ```
* **Step 3**: Locate the shortcuts you want to change (e.g., window navigation, application launchers, or system volume toggles).
* **Step 4**: Modify the key values according to the Hyprland Lua configuration syntax.
* **Step 5**: Save the file. The hotkey changes will automatically apply without needing to reboot your computer.

## Credits

- Hyprland: [https://hyprland.org](https://hyprland.org)
- Quickshell: [https://quickshell.outfoxxed.me](https://quickshell.outfoxxed.me)
- Cartoon Shell: [https://github.com/lesang2312/cartoon-shell](https://github.com/lesang2312/cartoon-shell)

## License

MIT License - Feel free to use and modify

## Support

For issues or questions, please open an issue on GitHub.

---

Made with ❤️ for the Hyprland community
