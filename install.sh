#!/bin/bash

# === CONFIG ===
EXT_ID="ophjlpahpchlmihnnnihgmmeilfjmjjc"
VIVALDI_DEB="vivaldi-stable_amd64.deb"
EXT_PATH="$HOME/.config/vivaldi/Default/Extensions/$EXT_ID"
ICON_URL="https://raw.githubusercontent.com/6MA-606/LINE-on-Vivaldi/main/assets/line-vivaldi.png"
ICON_PATH="/usr/share/icons/hicolor/256x256/apps/line-vivaldi.png"
DESKTOP_FILE="/usr/share/applications/line-vivaldi.desktop"
LAUNCH_CMD="vivaldi-stable --app=\"chrome-extension://$EXT_ID/index.html\" --window-size=800,600 --window-position=100,100"

# === Install Vivaldi if not present ===
if ! command -v vivaldi-stable &> /dev/null; then
    echo "🔧 Installing Vivaldi..."
    sudo apt update
    sudo apt install -y wget
    wget -qO "$VIVALDI_DEB" "https://downloads.vivaldi.com/stable/$VIVALDI_DEB"
    sudo dpkg -i "$VIVALDI_DEB" || sudo apt --fix-broken install -y
    rm "$VIVALDI_DEB"
    echo "✅ Vivaldi installed."
else
    echo "✅ Vivaldi already installed."
fi

# === Launch Vivaldi to install LINE extension ===
if [ ! -d "$EXT_PATH" ]; then
    echo "🧩 Launching Vivaldi to install LINE extension..."
    nohup vivaldi-stable "https://chrome.google.com/webstore/detail/line/$EXT_ID" >/dev/null 2>&1 &
    echo "⌛ Please install the LINE extension manually. Waiting for it to appear..."

    while [ ! -d "$EXT_PATH" ]; do
        sleep 5
        echo "🕒 Still waiting for LINE extension..."
    done

    echo "✅ LINE extension installed."
else
    echo "✅ LINE extension already installed."
fi

# === Create .desktop icon ===
echo "📝 Creating launcher shortcut..."

# === Download icon from GitHub ===
echo "🎨 Downloading icon from GitHub..."
TEMP_ICON="/tmp/line-vivaldi.png"
wget -qO "$TEMP_ICON" "$ICON_URL"
if [ -f "$TEMP_ICON" ]; then
    sudo mkdir -p "$(dirname "$ICON_PATH")"
    sudo mv "$TEMP_ICON" "$ICON_PATH"
    echo "✅ Icon downloaded and moved successfully."
else
    echo "❌ Failed to download icon, creating placeholder icon..."
    convert -size 256x256 xc:lightblue -gravity center -pointsize 32 -annotate 0 "LINE" "$TEMP_ICON"
    sudo mkdir -p "$(dirname "$ICON_PATH")"
    sudo mv "$TEMP_ICON" "$ICON_PATH"
fi

# === Write .desktop file ===
sudo tee "$DESKTOP_FILE" > /dev/null <<EOL
[Desktop Entry]
Name=LINE on Vivaldi
Comment=Open LINE Chat Extension on Vivaldi
Exec=$LAUNCH_CMD
Icon=$ICON_PATH
Terminal=false
Type=Application
Categories=Utility;
StartupWMClass=Vivaldi-stable
EOL

echo "✅ Launcher shortcut created."

# === Clean up ===
echo "🧹 Cleaning up..."
rm -f ./install.sh

sudo chmod +x "$DESKTOP_FILE"
sudo update-desktop-database /usr/share/applications/

echo "🎉 Launcher created: You can now open LINE on Vivaldi via your app menu!"
