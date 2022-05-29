#!/bin/sh

function setupBrew() {
    xcode-select -p > /dev/null || xcode-select --install

    if ! which brew > /dev/null || [ "$1" == "--init" ]; then
        ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
        eval "$(/opt/homebrew/bin/brew shellenv)"

        which brew || exit "brew not found"
        brew doctor
        brew update
    fi
}

function setupAsdf() {
    if ! which asdf > /dev/null || [ "$1" == "--init" ]; then
        echo 'install asdf'
	brew install asdf
    fi
}

function setupAnsible() {
    if ! which ansible-playbook > /dev/null || [ "$1" == "--init" ]; then
        echo 'install Ansbile'
        asdf plugin add python
        asdf install python latest
        asdf local python $(asdf list python)

        asdf plugin add ansible-core https://github.com/amrox/asdf-pyapp.git
        asdf install ansible-core latest
        asdf local ansible-core $(asdf list ansible-core)

        asdf reshim
        which ansible-playbook || exit 1
        ansible-galaxy collection install community.general
    fi

    echo 'localhost' > hosts
}

verbose='-vv'
if [ "$1" == "-v" ]; then
    verbose='-vvvv'
    shift 1
fi

setupBrew "$1"
setupAsdf "$1"
setupAnsible "$1"

HOMEBREW_CASK_OPTS="--appdir=~/Applications" ansible-playbook -i hosts ${verbose} ansible.playbook
