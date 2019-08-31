#!/bin/sh

# install cmake
sudo yum -y -q install cmake3

## get opencv and opencv_contrib
if [ ! -d "opencv" ]; then
    git clone https://github.com/opencv/opencv.git
fi
if [ ! -d "opencv_contrib" ]; then
    git clone https://github.com/opencv/opencv_contrib.git
fi

if [ ! -d "x264" ]; then
    git clone https://code.videolan.org/videolan/x264.git
fi

if [ ! -d "FFmpeg" ]; then
    git clone git@github.com:bitbytebit-cr/FFmpeg.git
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
                   -DBUILD_opencv_core=ON \
                   -DBUILD_opencv_imgproc=ON \
                   -DBUILD_opencv_img_hash=ON \
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
                   -DBUILD_opencv_highgui=OFF \
                   -DBUILD_opencv_imgcodecs=OFF \
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
    make

    # install opencv
    sudo make install

    cd ../../
fi

## Setup x264
if [ ! -f /usr/bin/x264 ]; then
    cd x264
    ./configure --prefix=/usr --disable-lavf --enable-static --enable-shared
    make -j 16
    sudo make install
    sudo ldconfig
    cd ../
fi

## Setup FFmpeg
if [ ! -f FFmpeg/ffmpeg ]; then
    cd FFmpeg
    ./configure --prefix=/usr --enable-libx264 --enable-gpl
    make -j 16
fi


