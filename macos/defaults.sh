#!/bin/bash
# what:        shared macOS `defaults write` settings for both machines
# when:        run by each machine's run_after_20-macos.sh on every chezmoi apply
# destructive: no — idempotent; restarts Dock/Finder only when a value actually changed

set -euo pipefail

changed=0

# set_default <domain> <key> <type> <value> — write only if different, so repeat
# applies stay quiet and Dock/Finder are only restarted on real changes (I5).
set_default() {
  local domain=$1 key=$2 type=$3 value=$4
  local current want
  current=$(defaults read "$domain" "$key" 2>/dev/null || echo "__unset__")
  want=$value
  if [[ $type == "-bool" ]]; then
    [[ $value == "true" ]] && want=1 || want=0
  fi
  if [[ "$current" != "$want" ]]; then
    defaults write "$domain" "$key" "$type" "$value"
    changed=1
    echo "defaults: $domain $key -> $value"
  fi
}

# --- Finder -------------------------------------------------------------------
set_default NSGlobalDomain AppleShowAllExtensions -bool true # show all file extensions
set_default com.apple.finder ShowPathbar -bool true          # path bar at bottom of Finder windows
set_default com.apple.finder ShowStatusBar -bool true        # item count + free space footer
set_default com.apple.finder FXPreferredViewStyle -string "Nlsv" # default to list view

# --- Keyboard ------------------------------------------------------------------
set_default NSGlobalDomain KeyRepeat -int 2                  # fastest key repeat
set_default NSGlobalDomain InitialKeyRepeat -int 15          # short delay before repeat
set_default NSGlobalDomain ApplePressAndHoldEnabled -bool false # hold = repeat, not accent picker

# --- Dock ----------------------------------------------------------------------
set_default com.apple.dock show-recents -bool false          # no "recent apps" section

# TODO(human): extend. Rule: every non-obvious key gets a comment saying what it
# changes in the UI. Machine-only settings go in that machine's run_after_20-macos.sh.

if [[ $changed -eq 1 ]]; then
  killall Dock 2>/dev/null || true
  killall Finder 2>/dev/null || true
  echo "macos/defaults.sh: settings changed; Dock/Finder restarted"
else
  echo "macos/defaults.sh: no changes"
fi
