#!/bin/sh

OS=$(uname -s)

echo
if [ "$OS" == "Darwin" ]; then
    echo "Setting up for Mac OS X"
    echo
    ./setupMacOSX.sh
elif [ "$OS" == "Linux" ]; then
    if [ -f /etc/redhat-release ]; then
        echo "Setting up for Linux CentOS 7"
        echo
        ./setupCentOS7.sh
    else
        echo "This Linux OS isn't supported. Try running ./setupCentOS7.sh manually if brave"
    fi
fi

if [ ! -d "video-splitter" ]; then
    git clone https://github.com/c0decracker/video-splitter.git
    chomd 755 video-splitter/ffmpeg-split.py
fi
echo
echo "encode and results tools are in bin/"
echo "video splitter is in video-splitter/"
echo "scripts to run tests in scripts/"
echo "tests directory is tests/"
