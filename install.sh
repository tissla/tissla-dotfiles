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

#  Packages
PKGS=(
	sddm          # desktop manager
    hyprland      # wm / compositor 
    hyprlock      # lockscreen
    hyprpaper     # wallpapers
    rofi          # launcher
    neovim        # editor
    quickshell    # de 
    alacritty     # terminal
)

echo "==> Installing packages:"
printf '  - %s\n' "${PKGS[@]}"

pacman -S --needed --noconfirm "${PKGS[@]}"

# Setup symlinks
USER_NAME="${SUDO_USER:-$USER}"
USER_HOME="$(eval echo "~$USER_NAME")"
USER_CONFIG="$USER_HOME/.config"

echo "==> Setting up config symlinks for $USER_NAME ($USER_HOME)"

mkdir -p "$USER_CONFIG"
ln -sfn "$USER_HOME/Dotfiles/alacritty"  "$USER_CONFIG/alacritty"
ln -sfn "$USER_HOME/Dotfiles/rofi"       "$USER_CONFIG/rofi"
ln -sfn "$USER_HOME/Dotfiles/waybar"     "$USER_CONFIG/waybar"
ln -sfn "$USER_HOME/Dotfiles/hypr"       "$USER_CONFIG/hypr"
ln -sfn "$USER_HOME/Dotfiles/quickshell" "$USER_CONFIG/quickshell"
ln -sfn "$USER_HOME/Dotfiles/nvim"       "$USER_CONFIG/nvim"
ln -sfn "$USER_HOME/Dotfiles/theme"      "$USER_CONFIG/theme"


# Setup sddm
USER_NAME="${SUDO_USER:-$USER}"
CONFIG_DIR="/etc/sddm.conf.d"

echo "==> Configuring SDDM autologin for user: $USER_NAME"

sudo mkdir -p "$CONFIG_DIR"

sudo tee "$CONFIG_DIR/autologin.conf" >/dev/null <<EOF
[Autologin]
User=$USER_NAME
Session=hyprland-uwsm
EOF

echo "==> SDDM autologin configured!"
echo "   User:    $USER_NAME"
echo "   Session: hyprland-uwsm"

systemctl enable --now sddm

echo "==> Finished! "
echo "==> Run systemctl restart sddm to start"


