#!/bin/sh

ss() {
    [ -f /usr/libexec/PlistBuddy ] || return
    domain=$(echo "$1" | sed -Ee 's/^([^.]+)$/com.apple.\1/')
    file="$HOME/Library/Preferences/${domain}.plist"
    key="$2"
    value="$3"
    previous=$(/usr/libexec/PlistBuddy -c "print \"$key\"" "$file")
    /usr/libexec/PlistBuddy -c "set \"$key\" \"$value\"" -c "save" "$file" > /dev/null
    current=$(/usr/libexec/PlistBuddy -c "print \"$key\"" "$file")
    echo "$key: $previous → $current"
}

gs() {
    [ -f /usr/libexec/PlistBuddy ] || return
    file=$(find "$HOME/Library/Preferences/ByHost" -name '.GlobalPreferences.*.plist')
    key="$1"
    value="$2"
    akey="com.apple.${1}"
    previous=$(/usr/libexec/PlistBuddy -c "print \"$akey\"" "$file")
    /usr/libexec/PlistBuddy -c "set \"$akey\" \"$value\"" -c "save" "$file" > /dev/null
    current=$(/usr/libexec/PlistBuddy -c "print \"$akey\"" "$file")
    echo "$key: $previous → $current"
}

s() {
    domain=$(echo "$1" | sed -Ee 's/^([^.]+)$/com.apple.\1/')
    key="$2"
    value="$3"
    type=$(defaults read-type "$domain" "$key" | sed -e 's/Type is /-/')
    previous=$(defaults read "$domain" "$key")
    defaults write "$domain" "$key" "$type" "$value"
    current=$(defaults read "$domain" "$key")
    echo "$key: $previous → $current"
}

p() {
    domain=$(echo "$1" | sed -Ee 's/^([^.]+)$/com.apple.\1/')
    key="$2"
    type=$(defaults read-type "$domain" "$key" | sed -e 's/Type is /-/')
    current=$(defaults read "$domain" "$key")
    echo "$key: $type $current"
}


# Dock & Menu Bar
# ---------------

## position on screen = Left
s dock orientation left

## Automatically hide and show the Dock = True
s dock autohide true


# Mission Control
#  see: https://github.com/NUIKit/CGSInternal/blob/master/CGSHotKeys.h
# ---------------

## Keyboard and Mouse Shortcuts > Mission Control = None
ss symbolichotkeys AppleSymbolicHotKeys:32:enabled false
ss symbolichotkeys AppleSymbolicHotKeys:44:enabled false
ss symbolichotkeys AppleSymbolicHotKeys:46:enabled false

## Keyboard and Mouse Shortcuts > Application Control = None
ss symbolichotkeys AppleSymbolicHotKeys:33:enabled false
ss symbolichotkeys AppleSymbolicHotKeys:45:enabled false
ss symbolichotkeys AppleSymbolicHotKeys:47:enabled false

## Keyboard and Mouse Shortcuts > Show Desktop = None
ss symbolichotkeys AppleSymbolicHotKeys:37:enabled false
ss symbolichotkeys AppleSymbolicHotKeys:48:enabled false
ss symbolichotkeys AppleSymbolicHotKeys:49:enabled false

## Hot Corners
##  see: https://ottan.xyz/posts/2016/07/system-preferences-terminal-defaults-mission-control/

### bottom-left = Mission Control
s dock wvous-bl-modifier 0
s dock wvous-bl-corner 2

### upper-right = Put Display to Sleep
s dock wvous-tr-modifier 0
s dock wvous-tr-corner 10

### bottom-right = Launchpad
s dock wvous-br-modifier 0
s dock wvous-br-corner 11


# Spotlight
# ---------
## Search Results > (all items) = False
for i in $(seq 0 20) ; do
  ss Spotlight "orderedItems:${i}:enabled"
done


# Keyboard
# --------

## Key Repeat = Fast
s .GlobalPreferences KeyRepeat 1

## Delay Until Repeat = Short
s .GlobalPreferences InitialKeyRepeat 10

## Shortcuts > Select the previous input source = False
ss symbolichotkeys AppleSymbolicHotKeys:60:enabled false

## Shortcuts > Select next source in input menu = False
ss symbolichotkeys AppleSymbolicHotKeys:61:enabled false


# Trackpad
# --------

## Secondary click = True
gs trackpad.enableSecondaryClick true

## Tap to click = True
s AppleMultitouchTrackpad Clicking true
gs mouse.tapBehavior 1

## Tracking spped
s .GlobalPreferences com.apple.trackpad.scaling 2.5


# Accessibility
# -------------

## Zoom > Use keyboard shortcuts to zoom = True
ss symbolichotkeys AppleSymbolicHotKeys:15:enabled true
ss symbolichotkeys AppleSymbolicHotKeys:17:enabled true
ss symbolichotkeys AppleSymbolicHotKeys:19:enabled true
ss symbolichotkeys AppleSymbolicHotKeys:23:enabled true
ss symbolichotkeys AppleSymbolicHotKeys:179:enabled true

## Pointer Controll > Trackpad Options > Enable dragging = without drag lock
s AppleMultitouchTrackpad Dragging true


# Terminal.app
## Profiles > Keyboard > Use Option as Meta key
ss Terminal "Startup Window Settings" Pro
ss Terminal "Default Window Settings" Pro
ss Terminal "Window Settings:Pro:useOptionAsMetaKey" true

# iterm2.app
ss com.googlecode.iterm2 "New Bookmarks:0:Right Option Key Sends" 2
ss com.googlecode.iterm2 "New Bookmarks:1:Right Option Key Sends" 2


# activate setting
# ----------------
/System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
killall Dock

echo ''
echo Please reboot to reflect all configurations.
