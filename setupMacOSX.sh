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
if [ ! -e /usr/local/bin/nasm]; then
    brew install nasm
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
if [ ! -e /usr/local/bin/cargo ]; then
    brew install rust
fi
if [ ! -e /usr/local/include/aom/aom.h ]; then
    brew install aom
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
if [ ! -e /usr/local/bin/cmake3 ]; then
    ln -s /usr/local/bin/cmake /usr/local/bin/cmake3
fi
if [ ! -e /usr/local/opt/opencv@3 ]; then
    brew install opencv@3
fi
if [ ! -e /usr/local/include/opencv2 ]; then
    # necessary to work
    brew link --force opencv@3
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
## setup dav1d
if [ ! -f /usr/local/bin/dav1d ]; then
    brew install dav1d
fi

# For some reason OpenCV3 doesn't create this link
if [ ! -e /usr/local/include/opencv2 -a -d /usr/local/include/opencv4 ]; then
    sudo ln -s /usr/local/include/opencv4/opencv2/ /usr/local/include/
fi

if [ ! -d "rav1e" ]; then
    git clone https://github.com/xiph/rav1e.git
    cd rav1e
    # TODO find stable version
    cd ../
fi

if [ ! -d "SVT-AV1" ]; then
    git clone https://github.com/OpenVisualCloud/SVT-AV1.git
    cd SVT-AV1
    # TODO find stable version
    cd ../
fi

if [ ! -d "SVT-VP9" ]; then
    git clone https://github.com/OpenVisualCloud/SVT-VP9.git
    cd SVT-VP9
    # TODO find stable version
    cd ../
fi

## Setup rav1e AV1
if [ ! -f /usr/local/lib/librav1e.a ]; then
    sudo cargo install cargo-c || echo "Already installed cargo-c"
    make rav1elib
fi

## Setup Intel SVT-AV1
if [ ! -f "/usr/local/lib/pkgconfig/SvtAv1Dec.pc" ]; then
  make svtav1libmac
fi

# Setup SVT-VP9
if [ ! -f "/usr/local/lib/pkgconfig/SvtVp9Enc.pc" ]; then
    #make svtvp9libmac
    echo "Skipping SVT-VP9, currently doesn't build on MacOS"
fi


if [ ! -d "FFmpeg" ]; then
    git clone https://git.ffmpeg.org/ffmpeg.git FFmpeg
    cd FFmpeg
    git checkout remotes/origin/release/4.2
    cat ../ffmpeg_modifications.diff | patch -p1
    cd ../
fi


## Setup FFmpeg
if [ ! -f FFmpeg/ffmpeg ]; then
    export PKG_CONFIG_PATH="/usr/local/opt/opencv@3/lib/pkgconfig"
    make ffmpegbinmac
fi

# build tools
g++ reference.cpp -o reference $(PKG_CONFIG_PATH="/usr/local/opt/opencv@3/lib/pkgconfig" pkg-config --cflags --libs opencv)

echo
echo "To install FFmpeg into /usr/bin/ffmpeg type: 'make install'"
echo "./FFmpeg/ffmpeg can be copied where you want also"

