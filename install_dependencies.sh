#!/bin/bash
# Template: OpenBazaar 
#
# install_dependencies.sh - Setup your Cryptonote development environment in one step.
#
# This script will only get better as its tested on more development environments
# if you can't modify it to make it better, please open an issue with a full
# error report at https://github.com/forknote/cryptonote-generator.git/issues/new
#
# Credits: Forknote
#
# Code borrowed from:
# https://github.com/OpenBazaar/OpenBazaar/blob/develop/configure.sh
# https://github.com/Quanttek/install_monero/blob/master/install_monero.sh
#exit on error
#!/bin/bash
set -e

function command_exists {
  # this should be a portable way of checking if something is on the path
  # usage: "if command_exists foo; then echo it exists; fi"
  command -v "$1" &> /dev/null
}

function brewDoctor {
  if ! brew doctor; then
    echo ""
    echo "'brew doctor' did not exit cleanly! This may be okay. Read above."
    echo ""
    read -p "Press [Enter] to continue anyway or [ctrl + c] to exit and do what the doctor says..."
  fi
}

function brewUpgrade {
  echo "If your Homebrew packages are outdated, we recommend upgrading them now. This may take some time."
  read -r -p "Do you want to do this? [y/N] " response
  if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]; then
    if ! brew upgrade; then
      echo ""
      echo "There were errors when attempting to 'brew upgrade' and there could be issues with the installation of Cryptonote generator."
      echo ""
      read -p "Press [Enter] to continue anyway or [ctrl + c] to exit and fix those errors."
    fi
  fi
}

function installMac {
  # install Homebrew if it is not installed, otherwise upgrade it
  if ! command_exists brew; then
    echo "installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
  else
    echo "updating, upgrading, checking Homebrew..."
    brew update
    brewDoctor
    brewUpgrade
  fi

  # install required dependencies if they aren't installed
  for dep in cmake boost python; do
    if ! command_exists "$dep"; then
      brew install "$dep"
    fi
  done

  doneMessage
}

function unsupportedOS {
  echo "Unsupported OS. Only macOS and Ubuntu are supported."
}


function installUbuntu {
  . /etc/os-release

  if [[ $ID == "ubuntu" && $VERSION_ID == "20.04" ]]; then
    sudo apt-get update
    sudo apt-get -y install build-essential python-dev gcc g++ git cmake libboost-all-dev librocksdb-dev

    doneMessage
  else
    echo "Only Ubuntu 20.04 is supported"
  fi
}

function doneMessage {
  echo "Cryptonote generator configuration finished."
  echo "type 'bash generator.sh [-h] [-f FILE] [-c <string>]' to generate Cryptonote coin."
}

if [[ $OSTYPE == linux-gnu || $OSTYPE == linux-gnueabihf ]]; then
  installUbuntu
else
  echo "Unsupported OS. Only Linux is supported."
fi