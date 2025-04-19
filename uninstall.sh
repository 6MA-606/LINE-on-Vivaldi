#!/bin/bash

# === CONFIG ===
EXT_ID="ophjlpahpchlmihnnnihgmmeilfjmjjc"
VIVALDI_PROFILE="$HOME/.config/vivaldi/Default"
ICON_PATH="/usr/share/icons/hicolor/256x256/apps/line-vivaldi.png"
DESKTOP_FILE="/usr/share/applications/line-vivaldi.desktop"
VIVALDI_DEB="vivaldi-stable_amd64.deb"

# === Function to remove LINE extension ===
remove_line_extension() {
    if [ -d "$VIVALDI_PROFILE/Extensions/$EXT_ID" ]; then
        echo "🧩 Removing LINE extension..."
        rm -rf "$VIVALDI_PROFILE/Extensions/$EXT_ID"
        rm -rf "$VIVALDI_PROFILE/Local Extension Settings/$EXT_ID"

        echo "✅ LINE extension removed."
    else
        echo "❌ LINE extension not found."
    fi
}

# === Function to remove Vivaldi ===
remove_vivaldi() {
    if command -v vivaldi-stable &> /dev/null; then
        echo "🔧 Do you want to remove Vivaldi? (y/n)"
        read -r REMOVE_VIVALDI
        if [[ "$REMOVE_VIVALDI" == "y" || "$REMOVE_VIVALDI" == "Y" ]]; then
            echo "🔧 Removing Vivaldi..."
            sudo apt-get remove --purge vivaldi-stable -y
            sudo apt-get autoremove -y
            echo "✅ Vivaldi removed."

            echo "🧹 Do you want to remove Vivaldi config files as well? (y/n)"
            read -r REMOVE_CONFIG
            if [[ "$REMOVE_CONFIG" =~ ^[yY]$ ]]; then
                rm -rf "$CONFIG_DIR"
                echo "✅ Config files removed."
            fi

        else
            echo "❌ Vivaldi will not be removed."
        fi
    else
        echo "❌ Vivaldi is not installed."
    fi
    
}

# === Check if Vivaldi is running and prompt to close ===
if pgrep -x "vivaldi" > /dev/null; then
    echo "⚠️ Vivaldi is running. Do you want to close it automatically? (y/n)"
    read -r CLOSE_VIVALDI
    if [[ "$CLOSE_VIVALDI" =~ ^[yY]$ ]]; then
        pkill -x "vivaldi-stable"
        sleep 1
    else
        echo "❌ Please close Vivaldi manually and try again."
        exit 1
    fi
fi


# === Prompt to remove LINE extension ===
echo "🧩 Do you want to remove the LINE extension from Vivaldi? (y/n)"
read -r REMOVE_LINE
if [[ "$REMOVE_LINE" =~ ^[yY]$ ]]; then
    remove_line_extension
else
    echo "❌ LINE extension will not be removed."
fi

# === Prompt to remove Vivaldi ===
remove_vivaldi

# === Remove .desktop file and icon ===
if [[ -f "$DESKTOP_FILE" || -f "$ICON_PATH" ]]; then
    echo "🧹 Removing .desktop shortcut and icon..."
    sudo rm -f "$DESKTOP_FILE"
    sudo rm -f "$ICON_PATH"
    echo "✅ Shortcut and icon removed."
else
    echo "❌ Shortcut or icon not found."
fi

# === Clean up any remaining files ===
echo "🧹 Cleaning up..."
rm -f ./uninstall.sh

echo "🎉 Uninstall process completed!"
