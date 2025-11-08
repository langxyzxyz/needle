#!/bin/bash

set -e

command_exists() {
  command -v "$@" 1>/dev/null 2>&1
}

setup_color() {
  RED=$(printf '\033[31m')
  GREEN=$(printf '\033[32m')
  YELLOW=$(printf '\033[33m')
  RESET=$(printf '\033[m')
}

info() {
  echo "${GREEN}[NEEDLE]${RESET}" "$@"
}

warn() {
  echo "${YELLOW}[NEEDLE]${RESET}" "$@"
}

error() {
  echo "${RED}[NEEDLE] Error:${RESET}" "$@"
}

setup_git() {
  info "setup git"

  info "config gitignore"
  ln -fsv "${NEEDLE}/git/gitignore" ~/.gitignore

  info "config gitconfig"
  if [ ! -f ~/.gitconfig ]; then
    cp -fpv "${NEEDLE}/git/template/gitconfig" ~/.gitconfig
    info "gitconfig created from template!"
  else
    warn "gitconfig existed!"
  fi
}

setup_python() {
  info "setup python"

  info "config pip.conf"
  ln -fsv "${NEEDLE}/python/pip.conf" ~/.pip.conf
}

setup_tmux() {
  info "setup tmux"

  info "config tmux.conf"
  ln -fsv "${NEEDLE}/tmux/tmux.conf" ~/.tmux.conf
}

setup_vi() {
  info "setup vi"

  info "config vim-plug extension"
  if [ ! -f ~/.vim/autoload/plug.vim ]; then
    curl -fsSLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    info "vim-plug installed!"
  else
    warn "vim-plug existed!"
  fi
}

setup_zsh() {
  info "setup zsh"

  info "config oh-my-zsh"
  if [ ! -d ~/.oh-my-zsh ]; then
    CHSH=no RUNZSH=no KEEP_ZSHRC=yes /bin/sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    info "oh-my-zsh installed!"
  else
    warn "oh-my-zsh existed!"
  fi

  info "config zsh theme"
  if [ ! -f ~/.oh-my-zsh/custom/themes/simple.zsh-theme ]; then
    cp -fpv "${NEEDLE}/zsh/template/simple.zsh-theme" ~/.oh-my-zsh/custom/themes/simple.zsh-theme
    info "zsh theme installed!"
  else
    warn "zsh theme existed!"
  fi
}

setup_node() {
  info "setup node"

  info "config nvm"
  if [ ! -d ~/.nvm ]; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.2/install.sh)"
    info "nvm installed!"
  else
    warn "nvm existed!"
  fi
}

main() {
  setup_color

  info "start"

  info "install xcode command line tools"
  if ! command_exists xcode-select || [[ -z $(xcode-select -p) ]]; then
    xcode-select --install
  fi

  info "install homebrew"
  if ! command_exists brew; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi

  info "update && upgrade brew"
  PATH=/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin
  brew update && brew upgrade

  info "install brews"
  brews=(
    cmake
    python3
    pipenv
    node
    fzf
    fd
    ripgrep
    httpie
    direnv
    vim
    tmux
    git
  )
  info "${brews[@]}"
  brew install -q "${brews[@]}"

  setup_git
  setup_python
  setup_tmux
  setup_vi
  setup_zsh
  setup_node

  info "done."
}

########################################
# main
########################################
export NEEDLE="${HOME}/dotfiles"
mkdir -p $NEEDLE
main
