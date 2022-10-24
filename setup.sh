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
    elif [ -f /etc/arch-release ]; then
        echo "Setting up for ArchLinux"
        echo
        ./setupArch.sh
    else
        echo "This Linux OS isn't supported. Try running ./setupCentOS7.sh or ./setupArch.sh manually if brave"
    fi
fi

echo
echo "encode and results tools are in bin/"
echo "scripts to run tests in scripts/"
echo "tests directory is tests/"
