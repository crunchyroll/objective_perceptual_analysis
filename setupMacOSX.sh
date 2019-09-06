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
if [ ! -e /usr/local/bin/wget ]; then
    brew install wget
fi
if [ ! -e /usr/local/bin/git ]; then
    brew install git
fi
if [ ! -e /usr/local/bin/x264 ]; then
    brew install x264
fi
if [ ! -e /usr/local/lib/libvmaf.a ]; then
    brew install libvmaf
fi
if [ ! -e /usr/local/bin/cmake ]; then
    brew install cmake
fi
if [ ! -e /usr/local/include/opencv4 ]; then
    brew install opencv@3
fi

# For some reason OpenCV3 doesn't create this link
if [ ! -e /usr/local/include/opencv2 ]; then
    sudo ln -s /usr/local/include/opencv4/opencv2/ /usr/local/include/
fi


if [ ! -d "FFmpeg" ]; then
    git clone git@github.com:bitbytebit-cr/FFmpeg_perceptual.git FFmpeg
fi

if [ ! -f "image006.jpg" ]; then
    wget https://kishoresblog.files.wordpress.com/2010/04/image006.jpg
    wget https://i.ytimg.com/vi/Z0aLjw52ip4/maxresdefault.jpg
fi

## Setup FFmpeg
if [ ! -f FFmpeg/ffmpeg ]; then
    make ffmpegbin
fi

# build tools
make reference

echo "To install FFmpeg into /usr/bin/ffmpeg type: 'make install'"
echo "./FFmpeg/ffmpeg can be copied where you want also"
