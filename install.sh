#!/bin/bash
progname="diskspeed"
error_exit() {
    local RED='\033[0;31m'
    local NC='\033[0m' # No Color
    echo -e "${RED}An error occured:${NC} Please try again."
    rm -rf "$TMPDIR/$progname"
    exit 1
}
cd "$TMPDIR" || error_exit
echo "Downloading $progname..."
git clone https://github.com/N-coder82/$progname.git $progname
cd "$TMPDIR/$progname" || error_exit
echo "Installing... (This may ask for sudo)"
chmod +x $progname.sh
sudo cp $progname.sh /usr/local/bin/$progname || error_exit
cd ..
rm -rf "$TMPDIR/$progname" || error_exit
echo "Finished."