#!/bin/sh

p() {
    # append 'com.apple.' if name is not start with '.'
    domain=$(echo "$1" | sed -Ee 's/^([^.]+)$/com.apple.\1/')
    file="$HOME/Library/Preferences/${domain}.plist"
    key="$2"
    current=$(/usr/libexec/PlistBuddy -c "print \"$key\"" "$file")
    echo "$key: $current"
}

s() {
    domain=$(echo "$1" | sed -Ee 's/^([^.]+)$/com.apple.\1/')
    file="$HOME/Library/Preferences/${domain}.plist"
    key="$2"
    value="$3"
    previous=$(/usr/libexec/PlistBuddy -c "print \"$key\"" "$file")
    /usr/libexec/PlistBuddy -c "set \"$key\" \"$value\"" -c "save" "$file" > /dev/null
    current=$(/usr/libexec/PlistBuddy -c "print \"$key\"" "$file")
    echo "$key: $previous → $current"
}

gp() {
    file=$(find "$HOME/Library/Preferences/ByHost" -name '.GlobalPreferences.*.plist')
    key="$1"
    akey="com.apple.${1}"
    current=$(/usr/libexec/PlistBuddy -c "print \"$akey\"" "$file")
    echo "$key: $current"
}

gs() {
    file=$(find "$HOME/Library/Preferences/ByHost" -name '.GlobalPreferences.*.plist')
    key="$1"
    value="$2"
    akey="com.apple.${1}"
    previous=$(/usr/libexec/PlistBuddy -c "print \"$akey\"" "$file")
    /usr/libexec/PlistBuddy -c "set \"$akey\" \"$value\"" -c "save" "$file" > /dev/null
    current=$(/usr/libexec/PlistBuddy -c "print \"$akey\"" "$file")
    echo "$key: $previous → $current"
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
s symbolichotkeys AppleSymbolicHotKeys:32:enabled false
s symbolichotkeys AppleSymbolicHotKeys:44:enabled false
s symbolichotkeys AppleSymbolicHotKeys:46:enabled false

## Keyboard and Mouse Shortcuts > Application Control = None
s symbolichotkeys AppleSymbolicHotKeys:33:enabled false
s symbolichotkeys AppleSymbolicHotKeys:45:enabled false
s symbolichotkeys AppleSymbolicHotKeys:47:enabled false

## Keyboard and Mouse Shortcuts > Show Desktop = None
s symbolichotkeys AppleSymbolicHotKeys:37:enabled false
s symbolichotkeys AppleSymbolicHotKeys:48:enabled false
s symbolichotkeys AppleSymbolicHotKeys:49:enabled false

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
  s Spotlight "orderedItems:${i}:enabled"
done


# Keyboard
# --------

## Key Repeat = Fast
s .GlobalPreferences KeyRepeat 1

## Delay Until Repeat = Short
s .GlobalPreferences InitialKeyRepeat 10

## Shortcuts > Select the previous input source = False
s symbolichotkeys AppleSymbolicHotKeys:60:enabled false

## Shortcuts > Select next source in input menu = False
s symbolichotkeys AppleSymbolicHotKeys:61:enabled false


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
s symbolichotkeys AppleSymbolicHotKeys:15:enabled true
s symbolichotkeys AppleSymbolicHotKeys:17:enabled true
s symbolichotkeys AppleSymbolicHotKeys:19:enabled true
s symbolichotkeys AppleSymbolicHotKeys:23:enabled true
s symbolichotkeys AppleSymbolicHotKeys:179:enabled true

## Pointer Controll > Trackpad Options > Enable dragging = without drag lock
s AppleMultitouchTrackpad Dragging true


# Terminal.app
## Profiles > Keyboard > Use Option as Meta key
s Terminal "Startup Window Settings" Pro
s Terminal "Default Window Settings" Pro
s Terminal "Window Settings:Pro:useOptionAsMetaKey" true

# iterm2.app
s com.googlecode.iterm2 "New Bookmarks:0:Right Option Key Sends" 2
s com.googlecode.iterm2 "New Bookmarks:1:Right Option Key Sends" 2


# activate setting
# ----------------
/System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
killall Dock

echo ''
echo Please reboot to reflect all configurations.
