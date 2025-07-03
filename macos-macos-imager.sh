#!/bin/bash

# macOS USB Installer Creator (Interactive)
# by alexbrunton

echo "🔍 Searching for macOS installers... (this may take a minute)"

# Find all macOS installers on the system
INSTALLERS=$(find /Applications / -type d -name "Install macOS *.app" 2>/dev/null)

if [ -z "$INSTALLERS" ]; then
    echo "❌ No macOS installers found on this system."
    echo "➡️ Download one from the App Store and try again."
    exit 1
fi

echo "📦 Found the following macOS installers:"
select INSTALLER in $INSTALLERS; do
    if [ -n "$INSTALLER" ]; then
        echo "✅ Selected: $INSTALLER"
        break
    else
        echo "⚠️ Invalid selection. Try again."
    fi
done

# Find all mounted volumes
echo "🔍 Scanning for USB drives..."
VOLUMES=$(ls /Volumes)

if [ -z "$VOLUMES" ]; then
    echo "❌ No mounted drives found in /Volumes."
    exit 1
fi

echo "💽 Found the following drives:"
select USB_NAME in $VOLUMES; do
    USB_PATH="/Volumes/$USB_NAME"
    if [ -d "$USB_PATH" ]; then
        echo "✅ Selected USB drive: $USB_PATH"
        break
    else
        echo "⚠️ Invalid selection. Try again."
    fi
done

# Confirm before wiping the USB
echo "⚠️ WARNING: This will ERASE all data on '$USB_PATH'."
echo "Are you absolutely sure? (yes/no)"
read CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    echo "🚫 Operation cancelled."
    exit 1
fi

# Run createinstallmedia
echo "💥 Creating USB installer from:"
echo "➡️ Installer: $INSTALLER"
echo "➡️ USB Drive: $USB_PATH"
sudo "$INSTALLER/Contents/Resources/createinstallmedia" \
    --volume "$USB_PATH" \
    --nointeraction

# Check result
if [ $? -eq 0 ]; then
    echo "✅ Success! Your USB installer is ready at $USB_PATH"
    echo "💻 Boot from it by holding Option (⌥) at startup."
else
    echo "❌ Failed to create USB installer."
    exit 1
fi
