#!/bin/sh
#
# Setup an FFmpeg with the ability to
# per title encode via image hashes
# hamming distance values

# Mac OS X
#
# requires:
#
# development tools
# brew
# nasm
# git
# wget
# cmake3
# opencv@3
# libx264

set -e

# install deps
if [ ! -e /usr/local/bin/mediainfo ]; then
    brew install mediainfo
fi
if [ ! -e /usr/local/bin/wget ]; then
    brew install wget
fi
if [ ! -e /usr/local/bin/git ]; then
    brew install git
fi
if [ ! -e /usr/local/bin/x264 ]; then
    brew install x264
fi
if [ ! -e /usr/local/lib/libvpx.a ]; then
    brew install libvpx
fi
if [ ! -e /usr/local/lib/libvmaf.a ]; then
    brew install libvmaf
fi
if [ ! -e /usr/local/lib/libass.a ]; then
    brew install libass
fi
if [ ! -e /usr/local/bin/cmake ]; then
    brew install cmake
fi
if [ ! -e /usr/local/include/opencv4 ]; then
    brew install opencv@3
fi
if [ ! -e /usr/local/bin/gnuplot ]; then
    brew install gnuplot
fi
if [ ! -e /usr/local/include/freetype2 ]; then
    brew install freetype2
fi
if [ ! -e /usr/local/include/fontconfig ]; then
    brew install fontconfig
fi

# For some reason OpenCV3 doesn't create this link
if [ ! -e /usr/local/include/opencv2 -a -d /usr/local/include/opencv4 ]; then
    sudo ln -s /usr/local/include/opencv4/opencv2/ /usr/local/include/
fi


if [ ! -d "FFmpeg" ]; then
    git clone https://git.ffmpeg.org/ffmpeg.git FFmpeg
    cd FFmpeg
    git checkout remotes/origin/release/4.2
    cat ../ffmpeg_perceptual.diff | patch -p1
    cd ../
fi


## Setup FFmpeg
if [ ! -f FFmpeg/ffmpeg ]; then
    export PKG_CONFIG_PATH="/usr/local/opt/opencv@3/lib/pkgconfig"
    make ffmpegbin
fi

# build tools
g++ reference.cpp -o reference $(PKG_CONFIG_PATH="/usr/local/opt/opencv@3/lib/pkgconfig" pkg-config --cflags --libs opencv)

echo "To install FFmpeg into /usr/bin/ffmpeg type: 'make install'"
echo "./FFmpeg/ffmpeg can be copied where you want also"

