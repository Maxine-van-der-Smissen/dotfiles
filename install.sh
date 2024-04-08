#!/bin/bash

# =======================================
# Script setup
# =======================================

set -e
set -o pipefail

# =======================================
# Helper functions
# =======================================

# Ask a question and return true or false based on the users input
ask() {
  # from https://djm.me/ask
  local prompt default reply

  while true; do

    if [ "${2:-}" = "Y" ]; then
      prompt="Y/n"
      default=Y
    elif [ "${2:-}" = "N" ]; then
      prompt="y/N"
      default=N
    else
      prompt="y/n"
      default=
    fi
    echo -n "$1 [$prompt] "
    read -r reply </dev/tty

    if [ -z "$reply" ]; then
      reply=$default
    fi

    case "$reply" in
    [Yy]*) return 0 ;;
    [Nn]*) return 1 ;;
    esac

  done
}

# delete target, create dirs if they don't exist yet and finally symlink the dir
function linkDir {
  rm -rf "$2"
  mkdir -p "${2%/*}"
  ln -sf "$1" "$2"
}

# replace line endings with a space (for use in package managers)
function fileToList {
  echo $(cat "$1" | sed '/^\s*#\([^!]\|$\)/d' | tr +'\n' ' ' | tr -s ' ')
}

# =======================================
# Installation functions
# =======================================

# install trizen, a aur helper
function install_trizen {
  git clone https://aur.archlinux.org/trizen.git
  pushd trizen || return
  makepkg -si
  popd || return
  sudo rm -dRf trizen/
}

# Sets up time and date related stuff
function setDateTimeConfig {
  systemctl enable ntpd
  timedatectl set-ntp true
  sudo ln -sf "$PWD"/config/networkmanager/09-timezone /etc/NetworkManager/dispatcher.d/09-timezone
}

# install other configs
function install_config {

  # link directories
  linkDir "$PWD"/wallpapers/images ~/Pictures/wallpapers
  linkDir "$PWD"/config/notify-osd/notify-osd ~/.notify-osd
  linkDir "$PWD"/config/terminal/xfce4-term ~/.config/xfce4/terminal
  linkDir "$PWD"/config/polybar ~/.config/polybar

  # link user files
  ln -sf "$PWD"/bash/.aliases ~/
  ln -sf "$PWD"/bash/.bashrc ~/.bashrc
  ln -sf "$PWD"/bash/.dotnet-install.sh ~/.dotnet-install.sh
  ln -sf "$PWD"/bash/.alias.sh ~/.alias
  ln -sf "$PWD"/config/nano/.nanorc ~/.nanorc
  ln -sf "$PWD"/bash/.powerline-shell.json ~/.powerline-shell.json
  ln -sf "$PWD"/config/gtk-3.0/settings.ini ~/.gtkrc-2.0.mine
  mkdir -p "$HOME/.config/gtk-3.0"
  ln -sf "$PWD"/config/gtk-3.0/settings.ini ~/.config/gtk-3.0/settings.ini
  ln -sf "$PWD"/config/mimeapps.list ~/.config/mimeapps.list
  ln -sf "$PWD"/config/greenclip.toml ~/.config/greenclip.toml
  ln -sf "$PWD"/config/terminalrc ~/.config/xfce4/terminal/terminalrc
  mkdir -p ~/.config/Code/User/globalStorage/zokugun.sync-settings
  ln -sf "$PWD"/config/git/settings.yml ~/.config/Code/User/globalStorage/zokugun.sync-settings/settings.yml

  mkdir -p ~/.config/rofi
  ln -sf "$PWD"/config/rofi/rofi.rasi ~/.config/rofi/config.rasi
  ln -sf "$PWD"/config/rofi/mytheme.rasi ~/.config/rofi/mytheme.rasi

  ln -sf "$PWD"/config/.gitconfig ~/.gitconfig
  ln -sf "$PWD"/config/.npmrc ~/.npmrc
  ln -sf "$PWD"/config/user-dirs.dirs ~/.config/user-dirs.dirs
  mkdir -p ~/.pulse
  ln -sf "$PWD"/config/pulse/daemon.conf ~/.pulse/daemon.conf
  ln -sf "$PWD"/config/picom.conf ~/.config/picom.conf

  # link autorandr files
  mkdir -p "$HOME/.config/autorandr"
  ln -sf "$PWD"/config/autorandr/postswitch ~/.config/autorandr/postswitch

  # link system files / directories
  sudo ln -sf "$PWD"/config/package-managers/pacman.conf /etc/pacman.conf
  sudo ln -sf "$PWD"/config/package-managers/makepkg.conf /etc/makepkg.conf
  sudo ln -sf "$PWD"/config/ntp.conf /etc/ntp.conf
  sudo ln -sf "$PWD"/bash/Completion/ /etc/bash_completion.d
  sudo ln -sf "$PWD"/config/environment /etc/environment
  sudo ln -sf "$PWD"/config/.bash_profile ~/.bash_profile

  # create empty .custom alias file
  echo "" >~/.custom
  echo "" >~/.variables

  # files to be copied once
  mkdir -p "$HOME/.config/Code/User"
  cp "$PWD"/config/code/syncLocalSettings.json ~/.config/Code/User/

  # system fixes
  echo fs.inotify.max_user_watches=524288 | sudo tee /etc/sysctl.d/40-max-user-watches.conf && sudo sysctl --system
  mkdir -p ~/Pictures/Screenshots

  setDateTimeConfig
}

# Installs the dependencies on Arch Linux
function install_dependencies {
  fileToList dependencies/pacman.txt | xargs sudo pacman --noconfirm -S

  install_trizen
  fileToList dependencies/aur.txt | xargs trizen -S --noconfirm
  fileToList dependencies/npm.txt | xargs sudo npm install -g
}

# set up a new ssh key
function create_ssh_key {
  ssh-keygen -t ed25519 -C "m.smissen@outlook.com"
  eval "$(ssh-agent -s)"
}

# =======================================
# User output functions
# =======================================

# Run the intro bit
function intro {
  echo "___  ___          _                      _           _     _     _ "
  echo "|  \/  |         | |                    (_)         | |   | |   ( )"
  echo "| .  . | __ _ ___| |_ ___ _ __ _ __ ___  _ _ __   __| |___| |__ |/ "
  echo "| |\/| |/ _\` / __| __/ _ \ '__| '_ \` _ \| | '_ \ / _' |_  / '_ \  "
  echo "| |  | | (_| \__ \ ||  __/ |  | | | | | | | | | | (_| |/ /| | | |  "
  echo "\_|  |_/\__,_|___/\__\___|_|  |_| |_| |_|_|_| |_|\__,_/___|_| |_|  "
  echo "                                                                   "
  echo "                                                                   "
  echo "                  __ _                       _                     "
  echo "                 / _(_)         ___         (_)                    "
  echo "  ___ ___  _ __ | |_ _  __ _   ( _ )    _ __ _  ___ ___            "
  echo " / __/ _ \| '_ \|  _| |/ _\` |  / _ \/\ | '__| |/ __/ _ \          "
  echo "| (_| (_) | | | | | | | (_| | | (_>  < | |  | | (_|  __/           "
  echo " \___\___/|_| |_|_| |_|\__, |  \___/\/ |_|  |_|\___\___|           "
  echo "                        __/ |                                      "
  echo "                       |___/                     "
  echo ""
}

# =======================================
# Main loop
# =======================================

clear
# Run the intro function
intro

ask "Do you want to continue installing my config and rice?" Y &&

  # Ask for dependency installation
  if ask "Do you want to install the applications listed in ./dependencies? (might prompt for password)" Y; then
    install_dependencies
  fi

# Ask for SSH generation
if ask "Do you want to generate a new SSH key?" Y; then
  create_ssh_key
fi

# Ask for config installation
if ask "Do you want to install the config files?" Y; then
  install_config
fi

clear

echo "Enjoy using my rice! :)"
