#!/usr/bin/env bash
# sm @old company

# Exit on error
# set -euo pipefail
# Causing issues with homebrew warnings for local Taps

# Get architecture: x86_64 or arm64
ARCH=$(uname -m)

# Add packages if needed...
PACKAGES=(
  coreutils
  gnu-sed
  gnu-tar
  gnu-indent
  gnu-which
  findutils
  git
  bat
  tmux
  readline
  zsh
  zsh-completions
  openssh
  python
  ruby
  mist
  openvpn
  vfuse
  samba
  ssh-copy-id
  speedtest-cli
  docker-compose
  neovim
)

CASKS=(
  appcleaner           # app remover
  iterm2               # shell
  microsoft-office     # office programs
  microsoft-teams      # microsoft teams
  adobe-acrobat-reader # pdf reader and compressor
  mattermost           # internal company chat
  macpass              # password manager
  firefox              # web browser
  google-chrome        # web browser
  thunderbird          # mail client
  keka                 # unarchiver/archiver
  tunnelblick          # openvpn client
  macdown              # markdown editor
  vlc                  # media player
  onyx                 # system repair
  reikey               # keylogging detector
  ransomwhere          # ransomware detector
  oversight            # video/audio spy detector
)

# Add applications if needed...
OPTIONAL_CASKS=(
  adobe-creative-cloud # to install after effects etc.
  sketch               # graphics program
  visual-studio-code   # code editor
  cyberduck            # sftp/ftp client
  github               # github / git gui client
  gitkraken            # gitkraken client
  temurin              # jdk 19
  temurin17            # jdk 17
  temurin11            # jdk 11
  temurin8             # jdk 8
  intellij-idea-ce     # Java IDE
  miro                 # collaborative whiteboard platform
  docker               # Docker Desktop
  ferdium              # multi web app application (mattermost,monday.com, gitlab etc.)
  zoom                 # app for meetings
  skype                # app for meetings
)

if [ "$ARCH" == arm64 ]; then
  echo "arm64 architecture detected. Installing Rosetta."
  softwareupdate --install-rosetta --agree-to-license
else
  echo "x86_64 architecture detected. Nothing to do."
fi

# Check for Homebrew to be present, install if it's missing
if test ! "$(which brew)"; then
  echo "Installing homebrew..."
  if /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; then
    echo "Homebrew installation successful."
  else
    echo "Homebrew installation failed."
    exit 1
  fi
fi

# set the correct BREW_PATH for each architectur
#if [ "$ARCH" == arm64 ]; then
# BREW_PATH="/opt/homebrew/bin/brew"
#else
#  BREW_PATH="/usr/local/bin/brew"
#fi

# Check if Homebrew executable exists
#if [ -x "$BREW_PATH" ]; then
#  echo "Setting up Homebrew environment..."
#  echo "eval $($BREW_PATH shellenv)" >>$HOME/.zprofile
#  eval "$($BREW_PATH shellenv)"
#else
#  echo "Error: Homebrew is not installed in the expected location ($BREW_PATH)"
#  exit 1
#fi

# export the BREW_PATH to .zshrc
#if [ -d "$BREW_PATH" ]; then
#  echo "Setting up Homebrew paths..."
#  echo 'export PATH="'$BREW_PATH':$PATH"' >>$HOME/.zshrc
#  echo 'export PATH="'$BREW_PATH'/sbin:$PATH"' >>$HOME/.zshrc
#else
#  echo "Error: Homebrew is not installed in the expected location ($BREW_PATH)"
#  exit 1
#fi

# Workaround, combination of architecture detection and BREW_PATH export does not work yet
if [ "$ARCH" == arm64 ]; then
  echo "eval $(/opt/homebrew/bin/brew shellenv)" >>$HOME/.zprofile
  eval "$(/opt/homebrew/bin/brew shellenv)"
  echo "export PATH=/opt/homebrew/bin:$PATH" >>$HOME/.zshrc
  echo "export PATH=/opt/homebrew/sbin:$PATH" >>$HOME/.zshrc
else
  echo "eval $(/usr/local/bin/brew shellenv)" >>$HOME/.zprofile
  eval "$(/usr/local/bin/brew shellenv)"
  echo "export PATH=/usr/local/bin:$PATH" >>$HOME/.zshrc
  echo "export PATH=/usr/local/sbin:$PATH" >>$HOME/.zshrc
fi

# Fix permissions
echo "Fixing permissions... (sometimes necessary)"
if [ "$ARCH" == arm64 ]; then
  sudo chown -R "$USER":admin /opt/homebrew/*
  sudo chmod -R g+rwx /opt/homebrew/*
else
  sudo chown -R "$USER":admin /usr/local/*
  sudo chmod -R g+rwx /usr/local/*
fi

# Security measure, install Casks which don't need root into ~/Applications, not /Applications
echo "export HOMEBREW_CASK_OPTS="--appdir=~/Applications"" >>$HOME/.zshrc
export HOMEBREW_CASK_OPTS="--appdir=~/Applications"

echo "Updating homebrew recipes..."
brew update
brew upgrade
brew tap homebrew/cask
brew tap homebrew/cask-fonts
brew doctor

echo "Installing packages..."
brew reinstall "${PACKAGES[@]}"

echo "enforcing macOS to use GNU tools..."
if [ "$ARCH" == "arm64" ]; then
  echo 'export PATH="/opt/homebrew/opt/findutils/libexec/gnubin:$PATH"' >>$HOME/.zshrc
else
  echo 'export PATH="/usr/local/opt/findutils/libexec/gnubin:$PATH"' >>$HOME/.zshrc
fi

echo "Installing apps..."
brew reinstall --cask "${CASKS[@]}"

read -p "Install additional apps? [y/N] " -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
  for cask in "${OPTIONAL_CASKS[@]}"; do
    read -p "Install $cask ? [y/N] " -r
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      if ! brew reinstall --cask $cask; then
        echo "Error installing $cask. Skipping..."
        sleep 1
      fi
    fi
  done
fi

echo "Cleaning up..."
brew cleanup
brew doctor

# Mount XYT share to install drivers, fonts, etc..
sudo mkdir /Volumes/smb
sudo chown "$USER":staff /Volumes/smb
mount_smbfs //installscript:RandomPassword@smbshare-server.local/Share /Volumes/smb

# Copy .pkg files
echo "Copying installers..."
cp "/Volumes/localvolume/IT/printer_driver/some_printer/fictional_driver.pkg" $HOME/Downloads/
cp "/Volumes/smbvolume/IT/printer_driver/some_printer/fictional_driver_update.pkg" $HOME/Downloads/
cp "/Volumes/smbvolume/IT/printer_driver/another_printer/another_fictional_driver.pkg" $HOME/Downloads/
cp "/Volumes/smbvolume/IT/software/Mac/Universal/some_MS_Office_stuff.pkg" $HOME/Downloads/

# Copy Bookmarks
echo "Copying bookmarks..."
cp -r "/Volumes/smbvolume/IT/Bookmarks" $HOME/Documents/

# Install fonts
echo "Installing fonts..."
find "/Volumes/smbvolume/corporate_identity/fonts/fonts_for_word_templates/" -name '*.ttf' -exec rsync -avh --no-perms --no-owner --no-group '{}' "$HOME/Library/Fonts/" ';'

# Install .pkg files
echo "Installing additional drivers..."
sudo installer -pkg "$HOME/Downloads/PostScript_driver.pkg" -target /
sudo installer -pkg "$HOME/Downloads/Update_Printer_Driver_Updater.pkg" -target /
sudo installer -pkg "$HOME/Downloads/another_fictional_driver.pkg" -target /
echo "Some MS Office stuff..."
sudo installer -pkg "$HOME/Downloads/some_MS_Office_stuff.pkg" -target /

# Cleanup .pkg files
echo "Cleaning up installers..."
rm "$HOME/Downloads/fictional_driver.pkg"
rm "$HOME/Downloads/fictional_driver_update.pkg"
rm "$HOME/Downloads/another_fictional_driver.pkg"
rm "$HOME/Downloads/some_MS_Office_stuff.pkg"

umount /Volumes/smbvolume

echo "Applying system settings..."

# Set hostname
read -p "Enter hostname: " -r newhostname
sudo scutil --set ComputerName "$newhostname"
sudo scutil --set HostName "$newhostname"
sudo scutil --set LocalHostName "$newhostname"
sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string "$newhostname"

# Set dock icons
defaults write com.apple.dock persistent-apps -array

for dockItem in {/System/Applications/{"Launchpad","Notes"},/Users/$USER/Applications/Thunderbird,/System/Cryptexes/App/System/Applications/Safari,/Users/$USER/Applications/{"Firefox","Google Chrome","Mattermost"},/Applications/{"Microsoft Teams","Microsoft Word","Microsoft Powerpoint","Microsoft Excel"},/Users/$USER/Applications/MacPass}.app; do
  defaults write com.apple.dock persistent-apps -array-add "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>$dockItem</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>"
done

killall Dock

# Automatically quit printer app once the print jobs complete
defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true

# Turn off keyboard illumination when computer is not used for 5 minutes
defaults write com.apple.BezelServices kDimTime -int 300

# set reasonable screenshot defaults
defaults write com.apple.screencapture location -string "$HOME/Desktop"
defaults write com.apple.screencapture type -string "png"

# Disable the sound effects on boot
sudo nvram SystemAudioVolume=""

# Trackpad: enable tap to click for this user and for the login screen
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

# Increase sound quality for Bluetooth headphones/headsets
defaults write com.apple.BluetoothAudioAgent "Apple Bitpool Min (editable)" -int 40

# Enable lid wakeup
sudo pmset -a lidwake 1

echo "Configuring Finder..."

# Avoiding the creation of .DS_Store files on network volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true

# Avoiding the creation of .DS_Store files on USB volumes
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# Finder: show all filename extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Automatically open a new Finder window when a volume is mounted
defaults write com.apple.frameworks.diskimages auto-open-ro-root -bool true
defaults write com.apple.frameworks.diskimages auto-open-rw-root -bool true
defaults write com.apple.finder OpenWindowForNewRemovableDisk -bool true

# Enable AirDrop over Ethernet
defaults write com.apple.NetworkBrowser BrowseAllInterfaces -bool true

# Reset Launchpad, but keep the desktop wallpaper intact
defaults write com.apple.dock ResetLaunchPad -bool true && killall Dock

# Show network volumes
defaults write com.apple.finder ShowMountedServersOnDesktop -bool true

killall Finder

echo "Configuring Safari..."

# Prevent Safari from opening "safe" files automatically after downloading
defaults write com.apple.Safari AutoOpenSafeDownloads -bool false

# Set Safaris home page
defaults write com.apple.Safari HomePage -string "https://some_homepage.de"

# Warn about fraudulent websites
defaults write com.apple.Safari WarnAboutFraudulentWebsites -bool true

# Block pop-up windows
defaults write com.apple.Safari WebKitJavaScriptCanOpenWindowsAutomatically -bool false
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaScriptCanOpenWindowsAutomatically -bool false

# Enable “Do Not Track”
defaults write com.apple.Safari SendDoNotTrackHTTPHeader -bool true

# Update extensions automatically
defaults write com.apple.Safari InstallExtensionUpdatesAutomatically -bool true

echo "Configuring Apple Mail..."

# Setting email addresses to copy as "foo@example.com" instead of "Foo Bar foo@example.com" in Mail
defaults write com.apple.mail AddressesIncludeNameOnPasteboard -bool false

# Show Attachments as Icons
defaults write com.apple.mail DisableInlineAttachmentViewing -bool true

echo "Configuring TextEdit..."

# Use plain text as default
defaults write com.apple.TextEdit RichText -int 0

# create untitled document at launch
defaults write com.apple.TextEdit NSShowAppCentricOpenPanelInsteadOfUntitledFile -bool false

echo "Configuring Software Update Settings..."

# Enable the automatic update check
defaults write com.apple.SoftwareUpdate AutomaticCheckEnabled -bool true

# Check for software updates daily, not just once per week
defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 1

# Download newly available updates in background
defaults write com.apple.SoftwareUpdate AutomaticDownload -int 1

# Install System data files & security updates
defaults write com.apple.SoftwareUpdate CriticalUpdateInstall -int 1

# Automatically download apps purchased on other Macs
defaults write com.apple.SoftwareUpdate ConfigDataInstall -int 1

# Turn on app auto-update
defaults write com.apple.commerce AutoUpdate -bool true

# recursively find and delete .DS_Store files
sudo find / -name '.DS_Store' -type f -delete

read -p "Reboot to apply changes? [Y/n] " -r
if [[ $REPLY =~ ^[Yy]$ || $REPLY == "" ]]; then
  sudo reboot
fi

echo "Bye!"
