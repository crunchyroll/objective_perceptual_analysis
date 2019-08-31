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

# install cmake
sudo yum -y -q install cmake3 || echo "all deps installed"

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

if [ ! -d "FFmpeg" ]; then
    git clone git@github.com:bitbytebit-cr/FFmpeg.git
fi

if [ ! -f "image006.jpg" ]; then
    wget https://kishoresblog.files.wordpress.com/2010/04/image006.jpg
    wget https://i.ytimg.com/vi/Z0aLjw52ip4/maxresdefault.jpg
fi

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

    cd ../../
fi

## Setup x264
if [ ! -f /usr/lib/libx264.a ]; then
    make x264lib
fi

## Setup FFmpeg
if [ ! -f FFmpeg/ffmpeg ]; then
    make ffmpeg
fi

# build tools
make
