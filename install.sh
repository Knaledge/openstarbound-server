#!/bin/bash

read -p "Enter Steam username: " STEAM_USER
read -sp "Enter Steam password: " STEAM_PASSWORD
echo

/steamcmd/steamcmd.sh \
    +force_install_dir /starbound/ \
    +login "$STEAM_USER" "$STEAM_PASSWORD" \
    +app_update 211820 validate \
    +quit

# Check if the SteamCMD login was successful
if [ $? -ne 0 ]; then
    echo "SteamCMD failed. Check the output for more details."
    exit 1
fi

response=$(curl -s "https://api.github.com/repos/xStarbound/xStarbound/releases/latest")

# Extract the tag name and download URL using jq
tag_name=$(echo "$response" | jq -r '.tag_name')
download_url=$(echo "$response" | jq -r '.assets[] | select(.name == "linux-static.tar.gz") | .browser_download_url')
assets_url=$(echo "$response" | jq -r '.assets[] | select(.name == "xSBassets.pak") | .browser_download_url')

if [ -n "$download_url" ]; then
    echo "Downloading linux-static.tar.gz from the latest release..."
    curl -L "$download_url" -o /tmp/linux-static.tar.gz
    
    echo "Downloading assets.pak from the latest release..."
    curl -L "$download_url" -o /tmp/assets.pak

    echo "Creating server folder"
    mkdir -p /starbound/server

    echo "Creating assets folder"
    mkdir -p /starbound/xsb-assets

    echo "Extracting linux-static.tar.gz ..."
    tar -xzf /tmp/linux-static.tar.gz -C /starbound/server

    echo "Extracting assets"
    cp /tmp/assets.pak /starbound/xsb-assets/xSBassets.pak

    echo "Cleaning up downloaded file..."
    rm /tmp/linux-static.tar.gz
    rm /tmp/assets.pak

    echo "Download and extraction completed successfully."
else
    echo "No linux-static.tar.gz asset found in the latest release."
    exit 1
fi