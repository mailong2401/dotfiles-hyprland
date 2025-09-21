#!/usr/bin/env python3
import subprocess
import shutil
import os
from pathlib import Path

HOME = Path.home()
SCRIPT_DIR = Path(__file__).parent

def run(cmd):
    print(f"[RUN] {cmd}")
    subprocess.run(cmd, shell=True, check=True)

def copy_configs():
    print("Sao chép file cấu hình cá nhân...")
    shutil.copytree(SCRIPT_DIR / ".config", HOME / ".config", dirs_exist_ok=True)
    shutil.copytree(SCRIPT_DIR / "Pictures", HOME / "Pictures", dirs_exist_ok=True)
    shutil.copy(SCRIPT_DIR / ".zshrc", HOME / ".zshrc")
    print("Hoàn tất sao chép.")

def update_system():
    print("Cập nhật hệ thống...")
    run("sudo pacman -Syu --noconfirm")

def install_packages():
    pkgs = [
        "hyprland", "neovim", "kitty", "wofi", "waybar", "zsh",
        "lsd", "ttf-jetbrains-mono-nerd", "brightnessctl", "swaybg",
        "iwd", "wl-clipboard", "otf-comicshanns-nerd", "python-pip",
        "npm", "nodejs", "ruby", "noto-fonts-cjk",
        "fcitx5", "fcitx5-configtool", "fcitx5-gtk", "fcitx5-qt",
        "fcitx5-unikey", "fcitx5-hangul", "thunar", "thunar-archive-plugin",
        "nvidia", "nvidia-utils", "nvidia-settings", "linux-headers",
        "grim", "slurp", "xdg-desktop-portal-hyprland"
    ]
    print("Cài đặt gói cần thiết...")
    run(f"sudo pacman -S --needed --noconfirm {' '.join(pkgs)}")

def install_zsh_plugins():
    plugins = {
        "zsh-autosuggestions": "https://github.com/zsh-users/zsh-autosuggestions",
        "zsh-syntax-highlighting": "https://github.com/zsh-users/zsh-syntax-highlighting"
    }
    for name, url in plugins.items():
        dest = HOME / f".oh-my-zsh/custom/plugins/{name}"
        if not dest.exists():
            print(f"Cài đặt plugin {name}...")
            run(f"git clone {url} {dest}")

def install_neovim_tools():
    print("Cài đặt plugin & tool cho Neovim...")
    run("sudo npm install -g neovim")
    run("gem install neovim")
    run("pip install --user neovim --break-system-packages")

def main():
    copy_configs()
    update_system()
    install_packages()
    # Cài Oh My Zsh không tương tác
    run('RUNZSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"')
    install_zsh_plugins()
    install_neovim_tools()

    answer = input("Bạn có muốn reboot không? (y/n): ").lower()
    if answer == "y":
        print("Đang reboot...")
        run("sudo reboot")
    else:
        print("Hủy reboot.")

if __name__ == "__main__":
    main()

