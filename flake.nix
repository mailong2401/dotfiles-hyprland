{
  description = "NixOS Hyprland + Dotfiles Module";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    dotfiles = {
      url = "github:mailong2401/dotfiles-hyprland";
      flake = false;
    };

    quickshell = {
      url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, dotfiles, quickshell, ... }: {
    # Xuất cấu hình dưới dạng một module tái sử dụng thay vì một system hardcode
    nixosModules.default = ({ pkgs, ... }: {

      ############################
      # Hyprland
      ############################
      programs.hyprland = {
        enable = true;
        xwayland.enable = true;
      };

      ############################
      # Dotfiles link
      ############################
      environment.etc."dotfiles-hyprland".source = dotfiles;

      ############################
      # Qt FIX (QUAN TRỌNG CHO QUICKSHELL)
      ############################
      environment.sessionVariables = {
        QML2_IMPORT_PATH = "${pkgs.qt6.qtdeclarative}/lib/qt-6/qml:${pkgs.qt6.qtmultimedia}/lib/qt-6/qml:${pkgs.qt6.qt5compat}/lib/qt-6/qml";
        QML_IMPORT_PATH  = "${pkgs.qt6.qtdeclarative}/lib/qt-6/qml:${pkgs.qt6.qtmultimedia}/lib/qt-6/qml:${pkgs.qt6.qt5compat}/lib/qt-6/qml";

        QT_PLUGIN_PATH = "${pkgs.qt6.qtbase}/lib/qt-6/plugins";

        XDG_SESSION_TYPE = "wayland";
        QT_QPA_PLATFORM = "wayland";
      };

      ############################
      # Packages
      ############################
      environment.systemPackages = with pkgs; [
        hyprland
        kitty

        quickshell.packages.x86_64-linux.default

        qt6.qtbase
        qt6.qtdeclarative
        qt6.qtmultimedia
        qt6.qt5compat
        qt6.qtwayland
        qt6.qtsvg
        qt6.qtimageformats

        git
        wget
        curl
        jq
        bc
        fish

        nautilus
        wl-clipboard
        grim
        slurp

        adw-gtk3
        papirus-icon-theme
      ];
    });
  };
}
