#!/usr/bin/env bash
set -euo pipefail

#  Root access
if [[ "$EUID" -ne 0 ]]; then
    echo "You must use sudo:"
    exit 1
fi

# start logo
./printlogo.sh

#  Update
echo "==> Updating (pacman -Syu)..."
pacman -Syu --noconfirm

# Setup user variables
USER_NAME="${SUDO_USER:-$USER}"
USER_HOME="$(eval echo "~$USER_NAME")"
USER_CONFIG="$USER_HOME/.config"

#  Pacman installations
PKGS=(
    base-devel
    kvantum
    kvantum-qt5
    qt6ct
    qt5ct
    swww
    adwaita-icon-theme      # standard cursor/icons
    pipewire                # audio
    ttf-jetbrains-mono-nerd # font
    sddm                    # desktop manager
    hyprland                # wm / compositor
    hyprlock                # lockscreen
    hyprpaper               # wallpapers
    rofi                    # launcher
    neovim                  # editor
    quickshell              # de
    alacritty               # terminal
)

echo "==> Installing packages:"
printf '  - %s\n' "${PKGS[@]}"

pacman -S --needed --noconfirm "${PKGS[@]}"

# AUR installations
install_aur() {
    local pkg="$1"
    local build_dir="/tmp/aur-$pkg"

    rm -rf "$build_dir"
    sudo -u "$USER_NAME" git clone "https://aur.archlinux.org/$pkg.git" "$build_dir"
    pushd "$build_dir" >/dev/null
    sudo -u "$USER_NAME" makepkg -si --noconfirm
    popd >/dev/null
    rm -rf "$build_dir"
}

echo "==> Installing AUR packages:"
install_aur kvantum-theme-catppuccin-git

# Kvantum / Catppuccin setup
sudo -u "$USER_NAME" mkdir -p "$USER_HOME/.config/Kvantum"
sudo -u "$USER_NAME" tee "$USER_HOME/.config/Kvantum/kvantum.kvconfig" >/dev/null <<'EOF'
[General]
theme=catppuccin-mocha-lavender#
EOF

mkdir -p "$USER_CONFIG"
# setup config files
sudo -u "$USER_NAME" mkdir -p "$USER_HOME/Dotfiles/hypr"
sudo -u "$USER_NAME" tee "$USER_HOME/Dotfiles/hypr/user.conf" >/dev/null <<EOF
user = $USER_NAME
EOF

# monitor (preferred mode)
sudo -u "$USER_NAME" tee "$USER_HOME/Dotfiles/hypr/monitors.conf" >/dev/null <<'EOF'
monitor = ,preferred,auto,1

EOF
# wallpapers
sudo -u "$USER_NAME" tee "$USER_HOME/Dotfiles/hypr/autostart.conf" >/dev/null <<'EOF'
$P1 = "$HOME/Dotfiles/wallpapers/nightskyempty.png"

exec-once = swww-daemon & sleep 0.1 && swww img "$P1" --transition-type none
exec-once = quickshell &

# lock on startup
exec-once = quickshell -p "$HOME/.config/quickshell/Lock/LockScreen.qml"
EOF

# workspaces
sudo -u "$USER_NAME" tee "$USER_HOME/Dotfiles/hypr/workspaces.conf" >/dev/null <<'EOF'
workspace = 1
workspace = 2
workspace = 3
workspace = 4
workspace = 5
workspace = 6
workspace = 7
workspace = 8
workspace = 9
EOF

# quickshell settings
sudo -u "$USER_NAME" tee "$USER_HOME/Dotfiles/quickshell/settings.json" >/dev/null <<'EOF'
{
  "bar": {
    "transparentBackground": false,
    "height": 40,
    "position": "bottom"
  },
  "defaultScreen": {
    "modules": {
      "left": ["workspaces"],
      "center": ["mpris"],
      "right": ["network", "volume", "calendar", "clock"]
    }
  },
  "screens": []
}
EOF

# setup symlinks
echo "==> Setting up config symlinks for $USER_NAME ($USER_HOME)"
sudo -u "$USER_NAME" ln -sfn "$USER_HOME/Dotfiles/alacritty" "$USER_CONFIG/alacritty"
sudo -u "$USER_NAME" ln -sfn "$USER_HOME/Dotfiles/rofi" "$USER_CONFIG/rofi"
sudo -u "$USER_NAME" ln -sfn "$USER_HOME/Dotfiles/waybar" "$USER_CONFIG/waybar"
sudo -u "$USER_NAME" ln -sfn "$USER_HOME/Dotfiles/hypr" "$USER_CONFIG/hypr"
sudo -u "$USER_NAME" ln -sfn "$USER_HOME/Dotfiles/quickshell" "$USER_CONFIG/quickshell"
sudo -u "$USER_NAME" ln -sfn "$USER_HOME/Dotfiles/nvim" "$USER_CONFIG/nvim"
sudo -u "$USER_NAME" ln -sfn "$USER_HOME/Dotfiles/theme" "$USER_CONFIG/theme"
sudo -u "$USER_NAME" ln -sfn "$USER_HOME/Dotfiles/wallpapers" "$USER_CONFIG/wallpapers"

# Setup sddm

echo "==> Configuring SDDM autologin for user: $USER_NAME"

sudo tee "/etc/sddm.conf" >/dev/null <<EOF
[Autologin]
User=$USER_NAME
Session=hyprland-uwsm
EOF

echo "==> SDDM autologin configured!"
echo "   User:    $USER_NAME"
echo "   Session: hyprland-uwsm"

systemctl enable --now sddm

echo "==> Finished! "
