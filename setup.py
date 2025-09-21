#!/usr/bin/env python3
import subprocess
import shutil
import time
import curses
import os
from pathlib import Path

HOME = Path(os.environ.get("HOME", "/root"))

SCRIPT_DIR = Path(__file__).parent
DRY_RUN = False  # True = test, False = chạy thật

# =========================
#       MÀU SẮC
# =========================
def color_print(msg, color_code=""):
    endc = "\033[0m"
    print(f"{color_code}{msg}{endc}")

# Foreground (màu chữ)
BLACK   = "\033[30m"
RED     = "\033[91m"
GREEN   = "\033[92m"
YELLOW  = "\033[93m"
BLUE    = "\033[94m"
MAGENTA = "\033[95m"
CYAN    = "\033[96m"
WHITE   = "\033[97m"
GRAY    = "\033[90m"
ORANGE  = "\033[38;5;208m"

# Background (màu nền)
BG_BLACK   = "\033[40m"
BG_RED     = "\033[101m"
BG_GREEN   = "\033[102m"
BG_YELLOW  = "\033[103m"
BG_BLUE    = "\033[104m"
BG_MAGENTA = "\033[105m"
BG_CYAN    = "\033[106m"
BG_WHITE   = "\033[107m"

# Reset màu
RESET = "\033[0m"

# Bold / Bright
BOLD   = "\033[1m"
UNDER  = "\033[4m"
ITALIC = "\033[3m"

# =========================
#       CHỌN NGÔN NGỮ (CURSES)
# =========================
def choose_language_curses(stdscr):
    curses.curs_set(0)
    options = ["Tiếng Việt", "English"]
    index = 0

    while True:
        stdscr.clear()
        stdscr.addstr("Chọn ngôn ngữ / Choose language:\n\n")
        for i, option in enumerate(options):
            if i == index:
                stdscr.addstr(f"> {option}\n", curses.A_REVERSE)
            else:
                stdscr.addstr(f"  {option}\n")
        stdscr.refresh()

        key = stdscr.getch()
        if key == curses.KEY_UP:
            index = (index - 1) % len(options)
        elif key == curses.KEY_DOWN:
            index = (index + 1) % len(options)
        elif key in [curses.KEY_ENTER, 10, 13]:
            return "vi" if index == 0 else "en"

LANG = curses.wrapper(choose_language_curses)
print(f"Ngôn ngữ đã chọn: {LANG}")

# =========================
#       TỪ ĐIỂN I18N
# =========================
MESSAGES = {
    "STEP_UPDATE": {"vi": "Đang cập nhật hệ thống...", "en": "Updating system..."},
    "STEP_COPY": {"vi": "Sao chép file cấu hình cá nhân...", "en": "Copying personal configuration files..."},
    "OK_COPY": {"vi": "Hoàn tất sao chép cấu hình.", "en": "Finished copying configuration."},
    "STEP_INSTALL_PACKAGES": {"vi": "Đang cài đặt các gói cơ bản: Hyprland, Neovim, Kitty, Wofi, Waybar, Zsh...",
                              "en": "Installing base packages: Hyprland, Neovim, Kitty, Wofi, Waybar, Zsh..."},
    "DRY_RUN": {"vi": "[DRY-RUN] Lệnh: ", "en": "[DRY-RUN] Command: "},
    "PRESS_ENTER": {"vi": "Nhấn Enter để tiếp tục...", "en": "Press Enter to continue..."},
    "REBOOT_PROMPT": {"vi": "Bạn có muốn reboot để hoàn tất cấu hình không? (y/n): ",
                      "en": "Do you want to reboot to finish the setup? (y/n): "},
    "INFO_REBOOT": {"vi": "Đang reboot hệ thống...", "en": "Rebooting system..."},
    "INFO_CANCEL": {"vi": "Hủy reboot, quá trình cài đặt đã hoàn tất.", "en": "Reboot canceled, setup completed."},
    "SKIP_PLUGIN": {"vi": "đã tồn tại, bỏ qua.", "en": "already exists, skipping."},
    "STEP_ZSH_PLUGIN": {"vi": "Đang cài đặt plugin Zsh: ", "en": "Installing Zsh plugin: "}
}

def wait_for_enter():
    color_print(MESSAGES["PRESS_ENTER"][LANG], CYAN)
    input()
    print()



# =========================
#       RUN COMMAND
# =========================
def run(cmd, msg=None):
    if msg:
        print(f"[INFO] {msg}")
    if DRY_RUN:
        color_print(f"{MESSAGES['DRY_RUN'][LANG]}{cmd}", GREEN)
        return
    try:
        # Thay vì stdout/stderr = DEVNULL, giữ mặc định để hiển thị realtime
        process = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
        for line in process.stdout:
            print(line, end="")  # realtime in ra terminal
        process.wait()
        if process.returncode != 0:
            color_print(f"[ERROR] Command failed: {cmd}", RED)
    except Exception as e:
        color_print(f"[ERROR] Có lỗi khi thực hiện: {cmd}\n{e}", RED)


# =========================
#       CÁC FUNCTION
# =========================
def copy_configs_curses(stdscr):
    stdscr.clear()
    stdscr.addstr(f"[STEP] {MESSAGES['STEP_COPY'][LANG]}\n", curses.A_BOLD)
    stdscr.refresh()
    try:
        shutil.copytree(SCRIPT_DIR / ".config", HOME / ".config", dirs_exist_ok=True)
        shutil.copytree(SCRIPT_DIR / "Pictures", HOME / "Pictures", dirs_exist_ok=True)
        shutil.copy(SCRIPT_DIR / ".zshrc", HOME / ".zshrc")
        stdscr.addstr(f"[OK] {MESSAGES['OK_COPY'][LANG]}\n", curses.color_pair(2))  # xanh lá
    except Exception as e:
        stdscr.addstr(f"[ERROR] Sao chép cấu hình thất bại: {e}\n", curses.color_pair(1))  # đỏ
    stdscr.addstr("\nNhấn phím bất kỳ để tiếp tục...")
    stdscr.refresh()
    stdscr.getch()  # chờ người dùng nhấn phím


#--------------------
# UPDATE SYSTEM     |
#--------------------
def update_system_curses(stdscr):
    curses.start_color()
    curses.init_pair(1, curses.COLOR_YELLOW, curses.COLOR_BLACK)  # Đang cập nhật
    curses.init_pair(2, curses.COLOR_GREEN, curses.COLOR_BLACK)   # Thành công
    curses.init_pair(3, curses.COLOR_RED, curses.COLOR_BLACK)     # Lỗi

    stdscr.clear()
    stdscr.addstr(f"[STEP] {MESSAGES['STEP_UPDATE'][LANG]}\n", curses.A_BOLD)
    stdscr.refresh()

    # Hiển thị trạng thái bắt đầu (màu vàng)
    stdscr.addstr("Đang cập nhật hệ thống...\n", curses.color_pair(1))
    stdscr.refresh()

    # Chạy pacman ẩn (stdout, stderr bỏ qua)
    result = subprocess.run(
        "sudo pacman -Syu --noconfirm",
        shell=True,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL
    )

    # Hiển thị trạng thái cuối cùng
    if result.returncode == 0:
        stdscr.addstr("Cập nhật thành công!\n", curses.color_pair(2))
    else:
        stdscr.addstr("Cập nhật thất bại!\n", curses.color_pair(3))

    stdscr.addstr("\nNhấn phím bất kỳ để tiếp tục...")
    stdscr.refresh()
    stdscr.getch()




#--------------------
# INSTALL PACKAGAES |
#--------------------
def install_packages_curses(stdscr):
    pkgs = ["hyprland", "wofi", "waybar", 
        "lsd", "ttf-jetbrains-mono-nerd", "brightnessctl", "swaybg",
        "iwd", "wl-clipboard", "otf-comicshanns-nerd", "noto-fonts-cjk",
        "fcitx5", "fcitx5-configtool", "fcitx5-gtk", "fcitx5-qt",
        "fcitx5-unikey", "fcitx5-hangul",
        "grim", "slurp", "xdg-desktop-portal-hyprland"]

    curses.start_color()
    # Khởi tạo các cặp màu
    curses.init_pair(1, curses.COLOR_YELLOW, curses.COLOR_BLACK)  # Đang tải / Đang giải nén
    curses.init_pair(2, curses.COLOR_GREEN, curses.COLOR_BLACK)   # Thành công
    curses.init_pair(3, curses.COLOR_RED, curses.COLOR_BLACK)     # Lỗi

    stdscr.clear()
    stdscr.addstr(f"[STEP] {MESSAGES['STEP_ZSH_PLUGIN'][LANG]}\n", curses.A_BOLD)
    stdscr.refresh()

    h, w = stdscr.getmaxyx()
    left_col_w = 30
    right_col_w = w - left_col_w - 2
    
    for i in range(h-1):
        stdscr.addstr(i, left_col_w + 2, "│")
    try:
        stdscr.addstr(h-1, 0, "─" * (w - 1))
    except curses.error:
        pass

    for i, pkg in enumerate(pkgs):
        if i + 2 < h - 1:
            stdscr.addstr(i + 2, 2, pkg[:left_col_w-2])
    stdscr.refresh()

    for i, pkg in enumerate(pkgs):
        if i + 2 >= h - 1:
            break

        cmd = f"sudo pacman -S --needed --noconfirm --verbose {pkg}"
        stdscr.addstr(i + 2, left_col_w + 4, " " * (right_col_w - 4))  
        
        # Trạng thái bắt đầu: màu vàng
        stdscr.addstr(i + 2, left_col_w + 4, "Đang bắt đầu...", curses.color_pair(1))
        stdscr.refresh()

        process = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True, bufsize=1)
        
        downloading = False
        extracting = False
        completed = False
        
        for line in process.stdout:
            line = line.strip()
            
            if "downloading" in line.lower() and not downloading:
                downloading = True
                status = "Đang tải..."
            elif "extracting" in line.lower() and not extracting:
                extracting = True
                status = "Đang giải nén..."
            elif "finished" in line.lower() or "complete" in line.lower():
                completed = True
                status = "Đã tải hoàn tất"
            
            if downloading or extracting or completed:
                display_status = status
                if downloading or extracting:
                    display_status += " [██████████]"

                stdscr.addstr(i + 2, left_col_w + 4, " " * (right_col_w - 4))
                stdscr.addstr(i + 2, left_col_w + 4, display_status[:right_col_w-4], curses.color_pair(1))
                stdscr.refresh()
        
        process.wait()
        
        # Hiển thị trạng thái cuối cùng: xanh nếu thành công, đỏ nếu lỗi
        if process.returncode == 0:
            final_status = "Đã cài đặt thành công"
            color = curses.color_pair(2)
        else:
            final_status = "Lỗi cài đặt"
            color = curses.color_pair(3)
        
        stdscr.addstr(i + 2, left_col_w + 4, " " * (right_col_w - 4))
        stdscr.addstr(i + 2, left_col_w + 4, final_status[:right_col_w-4], color)
        stdscr.refresh()

    msg = "Hoàn tất. Nhấn phím bất kỳ để tiếp tục..."
    stdscr.addstr(h - 1, 2, msg[:w-3])
    stdscr.refresh()
    stdscr.getch()






#--------------------
# INSTALL ZSH + PLUGINS |
#--------------------
def install_oh_my_zsh_and_plugins_curses(stdscr):
    stdscr.clear()
    stdscr.addstr(f"[STEP] {MESSAGES['STEP_INSTALL_PACKAGES'][LANG]}\n", curses.A_BOLD)
    stdscr.refresh()

    curses.start_color()
    curses.init_pair(1, curses.COLOR_YELLOW, curses.COLOR_BLACK)  # Đang tải
    curses.init_pair(2, curses.COLOR_GREEN, curses.COLOR_BLACK)   # Thành công
    curses.init_pair(3, curses.COLOR_RED, curses.COLOR_BLACK)     # Lỗi

    h, w = stdscr.getmaxyx()
    ohmyzsh_dir = HOME / ".oh-my-zsh"

    # ------------------ Cài Oh My Zsh ------------------
    if ohmyzsh_dir.exists():
        try:
            stdscr.addstr("[SKIP] Oh My Zsh đã tồn tại, bỏ qua.\n"[:w-1], curses.color_pair(2))
        except curses.error:
            pass
        stdscr.refresh()
    else:
        msg = "Đang cài Oh My Zsh không tương tác..."
        try:
            stdscr.addstr(msg[:w-1] + "\n", curses.color_pair(1))
        except curses.error:
            pass
        stdscr.refresh()

        process = subprocess.Popen(
            'export RUNZSH=yes; export CHSH=no; yes | sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"',
            shell=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
            bufsize=1
        )

        progress_width = min(20, w - 10)
        lines_seen = 0
        for _ in process.stdout:
            lines_seen += 1
            done = min(progress_width, lines_seen)
            bar = "█" * done + " " * (progress_width - done)
            percent = int(done / progress_width * 100)
            try:
                stdscr.addstr(f"\r[{bar}] {percent}%".ljust(w-1))
            except curses.error:
                pass
            stdscr.refresh()

        process.wait()

        try:
            if process.returncode == 0:
                stdscr.addstr("\nCài đặt Oh My Zsh thành công!\n"[:w-1], curses.color_pair(2))
            else:
                stdscr.addstr("\nCài đặt Oh My Zsh thất bại!\n"[:w-1], curses.color_pair(3))
        except curses.error:
            pass
        stdscr.refresh()

    # ------------------ Cài 2 plugin ------------------
    plugins = {
        "zsh-autosuggestions": "https://github.com/zsh-users/zsh-autosuggestions",
        "zsh-syntax-highlighting": "https://github.com/zsh-users/zsh-syntax-highlighting"
    }

    for name, url in plugins.items():
        dest = HOME / f".oh-my-zsh/custom/plugins/{name}"

        if dest.exists():
            stdscr.addstr(f"[SKIP] {name} {MESSAGES['SKIP_PLUGIN'][LANG]}\n", curses.color_pair(2))
            stdscr.refresh()
            continue

        stdscr.addstr(f"Đang cài plugin {name}...\n", curses.color_pair(1))
        stdscr.refresh()

        # Chạy git clone thực sự
        result = subprocess.run(
            f"git clone {url} {dest}",
            shell=True,
            stdout=subprocess.DEVNULL,  # không hiển thị output
            stderr=subprocess.DEVNULL
        )
        if result.returncode == 0:
            stdscr.addstr(f"{name} cài đặt thành công!\n", curses.color_pair(2))
        else:
            stdscr.addstr(f"{name} cài đặt thất bại!\n", curses.color_pair(3))
        stdscr.refresh()


    stdscr.addstr("\nNhấn phím bất kỳ để tiếp tục...\n"[:w-1])
    stdscr.refresh()
    stdscr.getch()

def main():
    curses.wrapper(update_system_curses)
    curses.wrapper(install_packages_curses)
    curses.wrapper(install_oh_my_zsh_and_plugins_curses)
    curses.wrapper(copy_configs_curses)
    answer = input(MESSAGES["REBOOT_PROMPT"][LANG]).lower()
    if answer == "y":
        print(MESSAGES["INFO_REBOOT"][LANG])
        run("sudo reboot")
    else:
        print(MESSAGES["INFO_CANCEL"][LANG])

if __name__ == "__main__":
    main()

