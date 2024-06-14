#!/bin/bash

error_exit() {
    local RED='\033[0;31m'
    local NC='\033[0m' # No Color
    echo -e "${RED}An error occured:${NC} Please try again."
    rm -rf "$TMPDIR/diskspeed"
    exit 1
}
cd "$TMPDIR" || error_exit
echo "Downloading diskspeed..."
git clone https://github.com/N-coder82/diskspeed.git diskspeed
cd "$TMPDIR/diskspeed" || error_exit
echo "Installing... (This may ask for sudo)"
chmod +x diskspeed.sh
sudo cp diskspeed.sh /usr/local/bin/diskspeed || error_exit
cd ..
rm -rf "$TMPDIR/diskspeed" || error_exit
echo "Finished."