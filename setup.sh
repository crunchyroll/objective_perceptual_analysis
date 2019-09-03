#!/bin/sh

OS=$(uname -s)

if [ "$OS" == "Darwin" ]; then
    echo "Setting up for Mac OS X"
    ./setupMacOSX.sh
elif [ "$OS" == "Linux" ]; then
    if [ -f /etc/redhat-release ]; then
        echo "Setting up for Linux CentOS 7"
    ./setupCentOS7.sh
    else
        echo "This Linux OS isn't supported. Try running ./setupCentOS7.sh manually if brave"
    fi
fi
