#!/bin/sh

function setupBrew() {
    xcode-select -p > /dev/null || xcode-select --install

    if ! which brew > /dev/null || [ "$1" == "--init" ]; then
        ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
        which brew || exit 1

        brew doctor
        brew update
    fi
}

function setupAnsible() {
    if ! which ansible-playbook > /dev/null || [ "$1" == "--init" ]; then
        echo 'install Ansbile'
        sudo easy_install pip
        sudo pip install ansible
        #brew install ansible
        which ansible-playbook || exit 1
    fi

    if [ ! -d hnakamur.homebrew-packages -o "$1" == "--init" ]; then
        ansible-galaxy install --roles-path=. hnakamur.homebrew-packages
        ansible-galaxy install --roles-path=. hnakamur.homebrew-cask-packages
        ansible-galaxy install --roles-path=. hnakamur.osx-defaults
    fi
    echo 'localhost' > hosts
}


setupBrew "$1"
setupAnsible "$1"

HOMEBREW_CASK_OPTS="--appdir=/Applications"  ansible-playbook -i hosts -vv ansible.playbook
