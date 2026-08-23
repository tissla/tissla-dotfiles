#!/usr/bin/env bash
set -euo pipefail

#  Root access
if [[ "$EUID" -ne 0 ]]; then
    echo "You must use sudo:"
    exit 1
fi

# start logo
"$(dirname "$0")/printlogo.sh"

echo "== > Choose compositor:"
select choice in "hyprland" "niri"; do
    COMPOSITOR=$choice
    break
done

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
    wl-clipboard            # clipboard
    tesseract               # base
    tesseract-data-eng      # eng pack
    tesseract-data-swe      # swe pack
    fastfetch               # vital
    btop                    # process monitor
    adwaita-icon-theme      # standard cursor/icons
    pipewire                # audio
    ttf-jetbrains-mono-nerd # font
    ttf-ibm-plex            #
    noto-fonts              #
    libnotify               # notify-send
    uwsm                    # wayland session manager
    $COMPOSITOR             # wm / compositor
    rofi                    # launcher
    neovim                  # editor
    quickshell              # de
    alacritty               # terminal
    matugen                 # custom themes
    obsidian                # need
    dolphin
    playerctl
    brightnessctl
    noto-fonts
    wireplumber
    unzip
    go
    fzf
    bash-completion
    eza
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
install_aur grimblast-git

# github installations (from latest release)
install_github_binary() {
    local url="$1"
    local name="$2"

    echo "==> Installing $name from github:"
    local tmp
    tmp="$(mktemp)"
    curl -fL "$url" -o "$tmp"
    install -Dm755 "$tmp" "/usr/bin/$name"

    rm -f "$tmp"
}

install_github_binary "https://github.com/tissla/tissla-wallpaper/releases/latest/download/twp-cli-linux-amd64" "twp-cli"
install_github_binary "https://github.com/tissla/tissla-wallpaper/releases/latest/download/twp-daemon-linux-amd64" "twp-daemon"

# create dotfile structure
echo "==> Creating Dotfiles structure..."
sudo -u "$USER_NAME" mkdir -p "$USER_HOME/Dotfiles/"{hypr,quickshell,theme,wallpapers,alacritty,rofi,nvim,Kvantum,bash}

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
  "wallpapersPath": "/../wallpapers",
  "screens": [
    {
      "name": "eDP-1",
      "isPrimary": true,
      "modules": {
        "left": ["workspaces"],
        "wallpaper": "default.png",
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
source="$HOME/Dotfiles/bash/colors"
PS1="\[${ACCENT}\]\u@\h \[${BLUE}\]\W\[${RESET}\]$ "

export LS_COLORS="di=${LS_DIR}:ln=${LS_LINK}:ex=${LS_EXEC}"

EOF
else
    echo "  skipping .bashrc (already exists)"
fi

# setup symlinks

if [[ "$COMPOSITOR" == "hyprland" ]]; then
    COMPFOLDER="hypr"
else
    COMPFOLDER="niri"
fi

echo "==> Setting up config symlinks for $USER_NAME ($USER_HOME)"
sudo -u "$USER_NAME" ln -sfn "$USER_HOME/Dotfiles/alacritty" "$USER_CONFIG/alacritty"
sudo -u "$USER_NAME" ln -sfn "$USER_HOME/Dotfiles/rofi" "$USER_CONFIG/rofi"
sudo -u "$USER_NAME" ln -sfn "$USER_HOME/Dotfiles/Kvantum" "$USER_CONFIG/Kvantum"
sudo -u "$USER_NAME" ln -sfn "$USER_HOME/Dotfiles/$COMPFOLDER" "$USER_CONFIG/$COMPFOLDER"
sudo -u "$USER_NAME" ln -sfn "$USER_HOME/Dotfiles/quickshell" "$USER_CONFIG/quickshell"
sudo -u "$USER_NAME" ln -sfn "$USER_HOME/Dotfiles/nvim" "$USER_CONFIG/nvim"
sudo -u "$USER_NAME" ln -sfn "$USER_HOME/Dotfiles/theme" "$USER_CONFIG/theme"
sudo -u "$USER_NAME" ln -sfn "$USER_HOME/Dotfiles/wallpapers" "$USER_CONFIG/wallpapers"
sudo -u "$USER_NAME" ln -sfn "$USER_HOME/Dotfiles/fastfetch" "$USER_CONFIG/fastfetch"
sudo -u "$USER_NAME" ln -sfn "$USER_HOME/Dotfiles/matugen" "$USER_CONFIG/matugen"
#generate default theme

echo "==> Generating default theme (tissla)..."
sudo -u "$USER_NAME" chmod +x "$USER_HOME/Dotfiles/build-theme.sh"
sudo -u "$USER_NAME" bash "$USER_HOME/Dotfiles/build-theme.sh" "tissla"

# Setup sddm

echo "==> Configuring autologin for user: $USER_NAME"

if [[ "$COMPOSITOR" == "hyprland" ]]; then
    START_CMD="uwsm start hyprland.desktop"
else
    START_CMD="niri-session"
fi

sudo mkdir -p /etc/systemd/system/getty@tty1.service.d
sudo tee "/etc/systemd/system/getty@tty1.service.d/autologin.conf" >/dev/null <<EOF
[Service]
ExecStart=
ExecStart=-/usr/bin/agetty --autologin $USER_NAME --noclear %I $TERM
EOF

sudo -u "$USER_NAME" tee "$USER_HOME/.bash_profile" >/dev/null <<EOF
if [[ -z "\$WAYLAND_DISPLAY" && "\$XDG_VTNR" == "1" ]]; then
    exec $START_CMD
fi
EOF

echo "==> Finished! "
