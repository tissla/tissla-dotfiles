#!/usr/bin/env bash
set -euo pipefail

#  Root access
if [[ "$EUID" -ne 0 ]]; then
    echo "You must use sudo:"
    exit 1
fi

# start logo
"$(dirname "$0")/printlogo.sh"

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
    awww                    # wallpapermanager
    wl-clipboard            # clipboard
    grimblast               # screenshots
    tesseract               # base
    tesseract-data-eng      # eng pack
    tesseract-data-swe      # swe pack
    fastfetch               # vital
    btop                    # process monitor
    adwaita-icon-theme      # standard cursor/icons
    pipewire                # audio
    ttf-jetbrains-mono-nerd # font
    sddm                    # desktop manager
    libnotify               # notify-send
    uwsm                    # wayland session manager
    hyprland                # wm / compositor
    rofi                    # launcher
    neovim                  # editor
    quickshell              # de
    alacritty               # terminal
    dolphin
    playerctl
    brightnessctl
    noto-fonts
    wireplumber
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

# create dotfile structure
echo "==> Creating Dotfiles structure..."
sudo -u "$USER_NAME" mkdir -p "$USER_HOME/Dotfiles/"{hypr,quickshell,theme,wallpapers,alacritty,rofi,nvim,Kvantum}

# create config files
echo "==> Creating config files..."

# Hypr configs
# REMOVED
# TODO: Add hypr default configs compatible with the new lua-format

# quickshell settings
SETTINGS_JSON="$USER_HOME/Dotfiles/quickshell/settings.json"
if [[ ! -f "$SETTINGS_JSON" ]]; then
    sudo -u "$USER_NAME" tee "$SETTINGS_JSON" >/dev/null <<'EOF'
{
  "bar": {
    "transparentBackground": false,
    "height": 30,
    "position": "bottom"
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
        "center": ["theme"],
        "right": ["battery", "cpu", "volume", "calendar", "clock"]
      }
    }
  ]
}
EOF
else
    echo "  skipping settings.json (already exists)"
fi

# Kvantum config
KVANTUM_CONF="$USER_HOME/Dotfiles/Kvantum/kvantum.kvconfig"
if [[ ! -f "$KVANTUM_CONF" ]]; then
    sudo -u "$USER_NAME" tee "$KVANTUM_CONF" >/dev/null <<'EOF'
[General]
theme=catppuccin-mocha-lavender#
EOF
else
    echo "  skipping kvantum.kvconfig (already exists)"
fi

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
BASHRC="$USER_HOME/.bashrc"
if [[ ! -f "$BASHRC" ]]; then
    sudo -u "$USER_NAME" tee "$BASHRC" >/dev/null <<'EOF'
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
else
    echo "  skipping .bashrc (already exists)"
fi

# fastfetch config
sudo -u "$USER_NAME" tee "$USER_HOME/Dotfiles/fastfetch/config.jsonc" >/dev/null <<EOF
{
  "\$schema": "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json",

  "logo": {
    "type": "file",
    "source": "$USER_HOME/.config/fastfetch/tissla.txt",
    "color": {
      "1": "#8b5cf6",
      "2": "#f9fafb",
      "3": "#374151"
    }
  },

  "display": {
    "separator": " : ",
    "color": {
      "keys": "#8b5cf6",
      "title": "#8b5cf6",
      "separator": "#374151",
      "output": "#f9fafb"
    },
    "key": { "width": 12 }
  },

  "modules": [
    { "type": "title" },

    "separator",

    { "type": "os",     "key": "OS",     "keyColor": "#8b5cf6", "outputColor": "#f9fafb" },
    { "type": "kernel", "key": "Kernel", "keyColor": "#8b5cf6", "outputColor": "#f9fafb" },
    { "type": "uptime", "key": "Uptime", "keyColor": "#8b5cf6", "outputColor": "#f9fafb" },
    { "type": "wm",     "key": "WM",     "keyColor": "#8b5cf6", "outputColor": "#f9fafb" },
    { "type": "theme",  "key": "Theme",  "keyColor": "#8b5cf6", "outputColor": "#f9fafb" },
    { "type": "font",   "key": "Font",   "keyColor": "#8b5cf6", "outputColor": "#f9fafb" },
    { "type": "cpu",    "key": "CPU",    "keyColor": "#8b5cf6", "outputColor": "#f9fafb" },
    { "type": "gpu",    "key": "GPU",    "keyColor": "#8b5cf6", "outputColor": "#f9fafb" },
    { "type": "memory", "key": "Mem",    "keyColor": "#8b5cf6", "outputColor": "#f9fafb" },
    { "type": "disk",   "key": "Disk",   "keyColor": "#8b5cf6", "outputColor": "#f9fafb" },

    "break",

    { "type": "colors", "symbol": "block", "paddingLeft": 1, "block": { "width": 3 } }
  ]
}
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
sudo -u "$USER_NAME" ln -sfn "$USER_HOME/Dotfiles/fastfetch" "$USER_CONFIG/fastfetch"

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
