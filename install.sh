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
    base-devel              # if not installed
    kvantum                 # desktop app theme manager
    kvantum-qt5             # desktop app theme manager
    qt6ct                   # qt framework
    qt5ct                   # qt framework
    qt6-5compat             # qt framework compat layer
    jq                      # json parser
    swww                    # wallpapermanager
    fastfetch               # vital
    btop                    # process monitor
    adwaita-icon-theme      # standard cursor/icons
    pipewire                # audio
    ttf-jetbrains-mono-nerd # font
    sddm                    # desktop manager
    libnotify               # notify-send
    swaync                  # notification daemon
    uwsm                    # wayland session manager
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

# create dotfile structure (needed)
echo "==> Creating Dotfiles structure..."
sudo -u "$USER_NAME" mkdir -p "$USER_HOME/Dotfiles/{hypr,quickshell,theme,swaync,wallpapers,alacritty,rofi,nvim,Kvantum,scripts}"

# create config files
echo "==> Creating config files..."

# Hypr configs
sudo -u "$USER_NAME" tee "$USER_HOME/Dotfiles/hypr/user.conf" >/dev/null <<EOF
user = $USER_NAME
EOF

sudo -u "$USER_NAME" tee "$USER_HOME/Dotfiles/hypr/monitors.conf" >/dev/null <<'EOF'
monitor = ,preferred,auto,1
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
    "height": 30,
    "position": "bottom"
  },
  "widgets": {
    "enabled": ["Battery", "Calendar", "CpuRam", "Devices", "Gpu", "Volume", "Network", "Theme"]
  },
  "theme": "tissla",
  "wallpapers": [ "default.png" ],
  "wallpapersPath": "/../wallpapers", 
  "screens": [
    {
      "name": "eDP-1",
      "isPrimary": true,
      "modules": {
        "left": ["workspaces"],
        "center": ["logo"],
        "right": ["battery", "cpu", "volume", "calendar", "clock"]
      }
    }
  ]
}
EOF

# Kvantum config
sudo -u "$USER_NAME" tee "$USER_HOME/Dotfiles/Kvantum/kvantum.kvconfig" >/dev/null <<'EOF'
[General]
theme=catppuccin-mocha-lavender#
EOF

# Qt configs
sudo -u "$USER_NAME" mkdir -p "$USER_HOME/.config/qt5ct"
sudo -u "$USER_NAME" tee "$USER_HOME/.config/qt5ct/qt5ct.conf" >/dev/null <<'EOF'
[Appearance]
style=kvantum
EOF

sudo -u "$USER_NAME" mkdir -p "$USER_HOME/.config/qt6ct"
sudo -u "$USER_NAME" tee "$USER_HOME/.config/qt6ct/qt6ct.conf" >/dev/null <<'EOF'
[Appearance]
style=kvantum
EOF

# bashrc
sudo -u "$USER_NAME" tee "$USER_HOME/.bashrc" >/dev/null <<'EOF'
#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='\[\033[01;35m\]\u@\h \[\033[38;2;86;156;214m\]\W\[\033[00m\]$ '

export LS_COLORS='di=38;5;74:ln=01;36:ex=01;32'

EOF
# setup symlinks
echo "==> Setting up config symlinks for $USER_NAME ($USER_HOME)"
sudo -u "$USER_NAME" ln -sfn "$USER_HOME/Dotfiles/alacritty" "$USER_CONFIG/alacritty"
sudo -u "$USER_NAME" ln -sfn "$USER_HOME/Dotfiles/rofi" "$USER_CONFIG/rofi"
sudo -u "$USER_NAME" ln -sfn "$USER_HOME/Dotfiles/Kvantum" "$USER_CONFIG/Kvantum"
sudo -u "$USER_NAME" ln -sfn "$USER_HOME/Dotfiles/hypr" "$USER_CONFIG/hypr"
sudo -u "$USER_NAME" ln -sfn "$USER_HOME/Dotfiles/quickshell" "$USER_CONFIG/quickshell"
sudo -u "$USER_NAME" ln -sfn "$USER_HOME/Dotfiles/nvim" "$USER_CONFIG/nvim"
sudo -u "$USER_NAME" ln -sfn "$USER_HOME/Dotfiles/theme" "$USER_CONFIG/theme"
sudo -u "$USER_NAME" ln -sfn "$USER_HOME/Dotfiles/wallpapers" "$USER_CONFIG/wallpapers"
sudo -u "$USER_NAME" ln -sfn "$USER_HOME/Dotfiles/swaync" "$USER_CONFIG/swaync"

#generate default theme

echo "==> Generating default theme (tissla)..."
sudo -u "$USER_NAME" chmod +x "$USER_HOME/Dotfiles/build-theme.sh"
sudo -u "$USER_NAME" bash "$USER_HOME/Dotfiles/build-theme.sh" "tissla"

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
