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
# pip for python3
if [ ! -e /usr/bin/pip3 ]; then
    sudo yum -y -q install python3-pip
fi
if [ ! -e /usr/bin/meson ]; then
    sudo python3 -m pip install meson
    sudo yum -y -q install meson
fi
if [ ! -e /usr/local/bin/ninja ]; then
    sudo python3 -m pip install ninja
fi
if [ ! -e /usr/bin/openssl ]; then
    sudo yum -y -q install openssl-devel
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
    git clone https://gitlab.com/AOMediaCodec/SVT-AV1.git
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
    git checkout d99f3dc6b211509d9f6bbb82bbb59bff86a9e3a5
    cat ../ffmpeg4_modifications.diff | patch -p1
    cd ../
fi

if [ ! -d "vmaf" ]; then
    git clone -b v1.3.15 https://github.com/Netflix/vmaf.git vmaf
    #if [ ! -f /usr/include/stdatomic.h ]; then
        #sudo wget https://gist.githubusercontent.com/nhatminhle/5181506/raw/541482dbc61862bba8a156edaae57faa2995d791/stdatomic.h -O /usr/include/stdatomic.h
    #fi
fi

# GCC 11.x install to /usr/local/
if [ ! -f "/usr/local/bin/gcc" ]; then
    sudo yum install -y -q centos-release-scl
    sudo yum install -y -q devtoolset-11-gcc*
fi

# requirement for x264
if [ ! -f "nasm-2.15.05.tar.bz2" ]; then
    wget --no-check-certificate https://www.nasm.us/pub/nasm/releasebuilds/2.15.05/nasm-2.15.05.tar.bz2
    tar xvfj nasm-2.15.05.tar.bz2
    cd nasm-2.15.05
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
    scl enable devtoolset-11 'cmake3 \
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
        ..'

    # build opencv
    scl enable devtoolset-11 'make -j$(nproc)'

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
    scl enable devtoolset-11 'make x264lib'
    sudo ldconfig
fi

## Setup VMAF
if [ ! -f /usr/local/lib/libvmaf.a ]; then
    scl enable devtoolset-11 'make vmaflib'
    sudo ln -s /usr/local/lib/pkgconfig/libvmaf.pc /usr/share/pkgconfig/
fi

## setup dav1d
if [ ! -f /usr/local/bin/dav1d ]; then
    #make dav1dlib
    #sudo ln -s /usr/local/lib64/pkgconfig/dav1d.pc /usr/share/pkgconfig
    sudo ldconfig
fi

## Setup VPX
if [ ! -f /usr/lib/libvpx.a ]; then
    scl enable devtoolset-11 'make vpxlib'
    sudo ldconfig
fi

## Setup AOM AV1
if [ ! -f /usr/lib/libaom.so ]; then
    scl enable devtoolset-11 'make aomlib'
    sudo ln -s /usr/lib/pkgconfig/aom.pc /usr/share/pkgconfig/
    sudo ldconfig
fi

# Setup SVT-AV1
if [ ! -f "/usr/local/lib/pkgconfig/SvtAv1Dec.pc" ]; then
    cd SVT-AV1/Build && \
    scl enable devtoolset-11 'cmake3 .. -G"Unix Makefiles" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_CXX_FLAGS="-I/usr/local/include -L/usr/local/lib" \
        -DCMAKE_C_FLAGS="-I/usr/local/include -L/usr/local/lib" \
        -DCMAKE_CXX_COMPILER=$(which g++) \
        -DCMAKE_CC_COMPILER=$(which gcc) \
        -DCMAKE_C_COMPILER=$(which gcc)' && \
    scl enable devtoolset-11 'make -j$(nproc)' && \
    sudo make install
    cd ../../
    sudo cp -f SVT-AV1/Build/SvtAv1Enc.pc /usr/share/pkgconfig/
    sudo cp -f SVT-AV1/Build/SvtAv1Dec.pc /usr/share/pkgconfig/
fi

# Setup SVT-VP9
if [ ! -f "/usr/local/lib/pkgconfig/SvtVp9Enc.pc" ]; then
    cd SVT-VP9/Build && \
    scl enable devtoolset-11 'cmake3 .. -G"Unix Makefiles" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_CXX_FLAGS="-I/usr/local/include -L/usr/local/lib" \
        -DCMAKE_C_FLAGS="-I/usr/local/include -L/usr/local/lib" \
        -DCMAKE_CXX_COMPILER=$(which g++) \
        -DCMAKE_CC_COMPILER=$(which gcc) \
        -DCMAKE_C_COMPILER=$(which gcc)' && \
    scl enable devtoolset-11 'make -j$(nproc)' && \
    sudo make install
    cd ../../
    sudo cp -f SVT-VP9/Build/SvtVp9Enc.pc /usr/share/pkgconfig/
fi

## Setup rav1e AV1
if [ ! -f /usr/local/lib/librav1e.a ]; then
    #make rav1elib
    #sudo ln -s /usr/local/lib/pkgconfig/rav1e.pc /usr/share/pkgconfig/
    # CentOS doesn't include /usr/local/lib by default
    #sudo touch /etc/ld.so.conf.d/local.conf
    #sudo echo "/usr/local/lib" >> /etc/ld.so.conf.d/local.conf
    #sudo echo "/usr/local/lib64" >> /etc/ld.so.conf.d/local.conf
    sudo ldconfig
fi

## Setup FFmpeg
if [ ! -f FFmpeg/ffmpeg ]; then
    scl enable devtoolset-11 'make ffmpegbin'
fi

# build tools
scl enable devtoolset-11 'make reference'

echo
echo "To install FFmpeg into /usr/bin/ffmpeg type: 'make install'"
echo "./FFmpeg/ffmpeg can be copied where you want also"

