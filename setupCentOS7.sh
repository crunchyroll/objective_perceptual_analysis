#!/bin/sh
#
# Setup an FFmpeg with the ability to
# per title encode via image hashes
# hamming distance values

# should run on Linux, other systems untested
#
# requires:
#
# git
# wget
# development tools

set -e

# install deps
if [ ! -e /usr/bin/wget ]; then
    sudo yum -y -q install wget
fi
if [ ! -e /usr/bin/git ]; then
    sudo yum -y -q install git
fi
if [ ! -e /usr/bin/clang ]; then
    sudo yum -y -q install clang
fi
if [ ! -e /usr/bin/cargo ]; then
    sudo yum -y -q install cargo
fi
if [ ! -e /usr/bin/rustc ]; then
    sudo yum -y -q install rust
fi
if [ ! -e /usr/bin/cmake3 ]; then
    sudo yum -y -q install cmake3
    sudo ln -s /usr/bin/cmake3 /usr/bin/cmake
fi
if [ ! -e /usr/bin/cmake ]; then
    sudo ln -s /usr/bin/cmake3 /usr/bin/cmake
fi
if [ ! -e /usr/bin/gnuplot ]; then
    sudo yum -y -q install gnuplot
fi
if [ ! -e /usr/bin/mediainfo ]; then
    sudo yum -y -q install mediainfo
fi
if [ ! -e /usr/include/freetype2 ]; then
    sudo yum -y -q install freetype-devel
fi
if [ ! -e /usr/lib/libass.a ]; then
    sudo yum -y -q install libass-devel
fi
if [ ! -e /usr/include/fontconfig ]; then
    sudo yum -y -q install fontconfig-devel
fi
if [ ! -e /usr/bin/meson ]; then
    sudo yum -y -q install meson
fi
if [ ! -e /usr/bin/nija ]; then
    sudo yum -y -q install ninja-build
fi

## get opencv and opencv_contrib
if [ ! -d "opencv" ]; then
    git clone https://github.com/opencv/opencv.git
    cd opencv
    git checkout 3.4
    cd ../
fi
if [ ! -d "opencv_contrib" ]; then
    git clone https://github.com/opencv/opencv_contrib.git
    cd opencv_contrib
    git checkout 3.4
    cd ../
fi

if [ ! -d "x264" ]; then
    git clone https://code.videolan.org/videolan/x264.git
    cd x264
    git checkout stable
    cd ../
fi

if [ ! -d "libvpx" ]; then
    git clone https://github.com/webmproject/libvpx.git libvpx
    cd libvpx
    git checkout v1.8.1
    cd ../
fi

if [ ! -d "aom" ]; then
    git clone https://aomedia.googlesource.com/aom/
    cd aom
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

if [ ! -d "dav1d" ]; then
    git clone https://code.videolan.org/videolan/dav1d.git
    cd dav1d
    # TODO find stable version
    cd ../
fi

if [ ! -d "rav1e" ]; then
    sudo cargo install cargo-c || echo "Already installed cargo-c"
    git clone https://github.com/xiph/rav1e.git
    cd rav1e
    # TODO find stable version
    cd ../
fi

if [ ! -d "FFmpeg" ]; then
    git clone https://git.ffmpeg.org/ffmpeg.git FFmpeg
    cd FFmpeg
    git checkout remotes/origin/release/4.2
    cat ../ffmpeg_modifications.diff | patch -p1
    cd ../
fi

if [ ! -d "vmaf" ]; then
    git clone -b v1.3.15 https://github.com/Netflix/vmaf.git vmaf
fi

# GCC 5.4.0 install to /usr/local/
if [ ! -f "/usr/local/bin/gcc" ]; then
    sh setupGCC_540.sh
fi
# setup path to point to GCC 5.4.0
export PATH=/usr/local/bin:$PATH
export LD_LIBRARY_PATH=/usr/local/lib64:$LD_LIBRARY_PATH

# requirement for x264
if [ ! -f "nasm-2.14.03rc2.tar.bz2" ]; then
    wget https://www.nasm.us/pub/nasm/releasebuilds/2.14.03rc2/nasm-2.14.03rc2.tar.bz2
    tar xvfj nasm-2.14.03rc2.tar.bz2
    cd nasm-2.14.03rc2
    ./configure --prefix=/usr
    make
    sudo make install
    cd ../
fi

if [ ! -d "opencv/build" ]; then
    cd opencv
    mkdir build
    cd build

    # build with only what we need
    cmake3 \
                   -DCMAKE_INSTALL_PREFIX=/usr \
                   -DCMAKE_INSTALL_LIBDIR=lib \
                   -DBUILD_SHARED_LIBS=True \
                   -DCMAKE_BUILD_TYPE=Release \
                   -DCMAKE_CXX_FLAGS="$CXXFLAGS" \
                   -DCMAKE_C_FLAGS="$CFLAGS" \
                   -DENABLE_PRECOMPILED_HEADERS=OFF \
                   -DWITH_OPENMP=OFF \
                   -WITH_OPENCL=OFF \
                   -DWITH_IPP=OFF \
                   -DBUILD_EXAMPLES=OFF \
                   -DWITH_FFMPEG=OFF -DWITH_JASPER=OFF -DWITH_PNG=OFF \
                   -DBUILD_opencv_python=OFF \
                   -DOPENCV_EXTRA_MODULES_PATH=../../opencv_contrib/modules \
                   -DOPENCV_GENERATE_PKGCONFIG=True \
                   -DBUILD_opencv_core=ON \
                   -DBUILD_opencv_imgproc=ON \
                   -DBUILD_opencv_img_hash=ON \
                   -DBUILD_opencv_imgcodecs=ON \
                   -DBUILD_opencv_highgui=ON \
                   -DBUILD_opencv_aruco=OFF \
                   -DBUILD_opencv_bgsegm=OFF \
                   -DBUILD_opencv_bioinspired=OFF \
                   -DBUILD_opencv_calib3d=OFF \
                   -DBUILD_opencv_ccalib=OFF \
                   -DBUILD_opencv_datasets=OFF \
                   -DBUILD_opencv_dnn=OFF \
                   -DBUILD_opencv_dnn_objdetect=OFF \
                   -DBUILD_opencv_dpm=OFF \
                   -DBUILD_opencv_face=OFF \
                   -DBUILD_opencv_features2d=OFF \
                   -DBUILD_opencv_flann=OFF \
                   -DBUILD_opencv_fuzzy=OFF \
                   -DBUILD_opencv_gapi=OFF \
                   -DBUILD_opencv_hfs=OFF \
                   -DBUILD_opencv_line_descriptor=OFF \
                   -DBUILD_opencv_ml=OFF \
                   -DBUILD_opencv_objdetect=OFF \
                   -DBUILD_opencv_optflow=OFF \
                   -DBUILD_opencv_phase_unwrapping=OFF \
                   -DBUILD_opencv_photo=OFF \
                   -DBUILD_opencv_plot=OFF \
                   -DBUILD_opencv_python2=OFF \
                   -DBUILD_opencv_quality=OFF \
                   -DBUILD_opencv_reg=OFF \
                   -DBUILD_opencv_rgbd=OFF \
                   -DBUILD_opencv_saliency=OFF \
                   -DBUILD_opencv_shape=OFF \
                   -DBUILD_opencv_stereo=OFF \
                   -DBUILD_opencv_stitching=OFF \
                   -DBUILD_opencv_structured_light=OFF \
                   -DBUILD_opencv_superres=OFF \
                   -DBUILD_opencv_surface_matching=OFF \
                   -DBUILD_opencv_text=OFF \
                   -DBUILD_opencv_tracking=OFF \
                   -DBUILD_opencv_ts=OFF \
                   -DBUILD_opencv_video=OFF \
                   -DBUILD_opencv_videoio=OFF \
                   -DBUILD_opencv_videostab=OFF \
                   -DBUILD_opencv_xfeatures2d=OFF \
                   -DBUILD_opencv_ximgproc=OFF \
                   -DBUILD_opencv_xobjdetect=OFF \
                   -DBUILD_opencv_xphoto=OFF \
                   ..

    # build opencv
    make -j8

    # install opencv
    sudo make install

    # For some reason OpenCV3 doesn't create this link
    if [ ! -e /usr/include/opencv2 -a -d /usr/include/opencv4 ]; then
        sudo ln -s /usr/include/opencv4/opencv2/ /usr/include/
    fi

    sudo ldconfig

    cd ../../
fi

## Setup x264
if [ ! -f /usr/lib/libx264.a ]; then
    make x264lib
    sudo ldconfig
fi

## Setup VMAF
if [ ! -f /usr/local/lib/libvmaf.a ]; then
    make vmaflib
    sudo ln -s /usr/local/lib/pkgconfig/libvmaf.pc /usr/share/pkgconfig/
fi

## setup dav1d
if [ ! -f /usr/local/bin/dav1d ]; then
    make dav1dlib
    sudo ln -s /usr/local/lib64/pkgconfig/dav1d.pc /usr/share/pkgconfig
    sudo ldconfig
fi

## Setup VPX
if [ ! -f /usr/lib/libvpx.a ]; then
    make vpxlib
    sudo ldconfig
fi

## Setup AOM AV1
if [ ! -f /usr/lib/libaom.so ]; then
    make aomlib
    sudo ln -s /usr/lib/pkgconfig/aom.pc /usr/share/pkgconfig/
    sudo ldconfig
fi

# Setup SVT-AV1
if [ ! -f "/usr/local/lib/pkgconfig/SvtAv1Dec.pc" ]; then
    make svtav1lib
    sudo cp -f SVT-AV1/Build/SvtAv1Enc.pc /usr/share/pkgconfig/
    sudo cp -f SVT-AV1/Build/SvtAv1Dec.pc /usr/share/pkgconfig/
fi

# Setup SVT-VP9
if [ ! -f "/usr/local/lib/pkgconfig/SvtVp9Enc.pc" ]; then
    make svtvp9lib
    sudo cp -f SVT-VP9/Build/SvtVp9Enc.pc /usr/share/pkgconfig/
fi

## Setup rav1e AV1
if [ ! -f /usr/local/lib/librav1e.a ]; then
    make rav1elib
    sudo ln -s /usr/local/lib/pkgconfig/rav1e.pc /usr/share/pkgconfig/
    # CentOS doesn't include /usr/local/lib by default
    sudo echo "/usr/local/lib" >> /etc/ld.so.conf.d/local.conf
    sudo echo "/usr/local/lib64" >> /etc/ld.so.conf.d/local.conf
    sudo ldconfig
fi

## Setup FFmpeg
if [ ! -f FFmpeg/ffmpeg ]; then
    make ffmpegbin
fi

# build tools
make reference

echo
echo "To install FFmpeg into /usr/bin/ffmpeg type: 'make install'"
echo "./FFmpeg/ffmpeg can be copied where you want also"

