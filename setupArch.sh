#!/bin/bash

mkdir ~/_opaencoder_deps
cd ~/_opaencoder_deps

pacman --noconfirm -Syu
pacman --noconfirm -S \
    base-devel \
    git \
    cmake \
    nasm \
    x264 \
    dav1d \
    libvpx \
    aom \
    svt-av1 \
    svt-vp9 \
    rav1e \
    ffms2 \
    libmagick \
    tesseract \
    zimg \
    cython \
    meson \
    cargo \
    fftw \
    python-pip \
    gnuplot \
    mediainfo

# build opencv
git clone https://github.com/opencv/opencv.git
git clone https://github.com/opencv/opencv_contrib.git
cd opencv_contrib
git checkout 3.4
cd ..
cd opencv
git checkout 3.4
mkdir build
cd build
cmake \
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
    .. && \
    make -j$(nproc) && make install && ldconfig

# build vmaf
cd ~/_opaencoder_deps
git clone -b v1.3.15 https://github.com/Netflix/vmaf.git vmaf
cd vmaf
make -j$(nproc) && make install && ldconfig

# build ffmpeg
cd ~/_opaencoder_deps
git clone https://git.ffmpeg.org/ffmpeg.git
cd ffmpeg
git checkout tags/n5.1.2
cat /opaencoder/ffmpeg_modifications.diff | patch -p1
./configure --prefix=/usr \
    --enable-libx264 \
    --enable-libvpx \
    --enable-gpl \
    --enable-libopencv \
    --enable-version3 \
    --enable-libvmaf \
    --enable-libfreetype \
    --enable-fontconfig \
    --enable-libass \
    --enable-libaom \
    --enable-libsvtav1 && \
    make -j$(nproc) && make install && ldconfig

# build vapoursynth
cd ~/_opaencoder_deps
git clone https://github.com/vapoursynth/vapoursynth.git
cd vapoursynth
./autogen.sh && ./configure --prefix=/usr && make -j$(nproc) && make install && ldconfig

# build vapoursynth plugins

# ffms2
cd ~/_opaencoder_deps
git clone https://github.com/FFMS/ffms2.git
cd ffms2
./autogen.sh && ./configure --libdir=/usr/lib/vapoursynth && make -j$(nproc) && make install

# lsmash
cd ~/_opaencoder_deps
git clone https://github.com/l-smash/l-smash.git
cd l-smash
./configure --enable-shared && make -j$(nproc) && make install
cd ~/_opaencoder_deps
git clone https://github.com/AkarinVS/L-SMASH-Works.git
cd L-SMASH-Works/VapourSynth
git checkout ffmpeg-4.5
meson build && ninja -C build && ninja -C build install

# addgrain
cd ~/_opaencoder_deps
git clone https://github.com/HomeOfVapourSynthEvolution/VapourSynth-AddGrain.git
cd VapourSynth-AddGrain
meson build && ninja -C build && ninja -C build install

# adaptivegrain
cd ~/_opaencoder_deps
git clone https://github.com/Irrational-Encoding-Wizardry/adaptivegrain.git
cd adaptivegrain
cargo build --release && cp target/release/libadaptivegrain_rs.so /usr/lib/vapoursynth/

# bm3d
cd ~/_opaencoder_deps
git clone https://github.com/HomeOfVapourSynthEvolution/VapourSynth-BM3D.git
cd VapourSynth-BM3D
meson build && ninja -C build && ninja -C build install

# continuityfixer
cd ~/_opaencoder_deps
git clone https://github.com/MonoS/VS-ContinuityFixer.git
cd VS-ContinuityFixer
g++ -I /usr/include/vapoursynth -fPIC continuity.cpp -O2 -msse2 -mfpmath=sse -shared -o continuity.so && \
    cp continuity.so /usr/lib/vapoursynth

# ctmf
cd ~/_opaencoder_deps
git clone https://github.com/HomeOfVapourSynthEvolution/VapourSynth-CTMF.git
cd /root/opaencoder/_deps/VapourSynth-CTMF
meson build && ninja -C build && ninja -C build install

# dctfilter
cd ~/_opaencoder_deps
git clone https://bitbucket.org/mystery_keeper/vapoursynth-dctfilter
cd vapoursynth-dctfilter/src
gcc -I /usr/lib/vapoursynth -fPIC main.c -O2 -msse2 -shared -o dctfilter.so && cp dctfilter.so /usr/lib/vapoursynth

# deblock
cd ~/_opaencoder_deps
git clone https://github.com/HomeOfVapourSynthEvolution/VapourSynth-Deblock.git
cd VapourSynth-Deblock
meson build && ninja -C build && ninja -C build install

# descale
cd ~/_opaencoder_deps
git clone https://github.com/Frechdachs/vapoursynth-descale.git
cd vapoursynth-descale
meson build && ninja -C build && ninja -C build install

# dfttest
cd ~/_opaencoder_deps
git clone https://github.com/HomeOfVapourSynthEvolution/VapourSynth-DFTTest.git
cd VapourSynth-DFTTest
meson build && ninja -C build && ninja -C build install

# eedi2
cd ~/_opaencoder_deps
git clone https://github.com/HomeOfVapourSynthEvolution/VapourSynth-EEDI2.git
cd VapourSynth-EEDI2
meson build && ninja -C build && ninja -C build install

# eedi3
cd ~/_opaencoder_deps
git clone https://github.com/HomeOfVapourSynthEvolution/VapourSynth-EEDI3.git
cd VapourSynth-EEDI3
meson build -Dopencl=false && ninja -C build && ninja -C build install

# f3kdb
cd ~/_opaencoder_deps
git clone https://github.com/SAPikachu/flash3kyuu_deband.git
cd flash3kyuu_deband
./waf configure --libdir=/usr/lib/vapoursynth && ./waf build && ./waf install

# fmtconv
cd ~/_opaencoder_deps
git clone https://github.com/EleonoreMizo/fmtconv.git
cd fmtconv/build/unix
./autogen.sh && ./configure --libdir=/usr/lib/vapoursynth && make -j$(nproc) && make install

# mvtools
cd ~/_opaencoder_deps
git clone https://github.com/dubhater/vapoursynth-mvtools.git
cd vapoursynth-mvtools
meson build && ninja -C build && ninja -C build install

# nnedi3
cd ~/_opaencoder_deps
git clone https://github.com/dubhater/vapoursynth-nnedi3.git
cd vapoursynth-nnedi3
./autogen.sh && ./configure --libdir=/usr/lib/vapoursynth && make -j$(nproc) && make install

# retinex
cd ~/_opaencoder_deps
git clone https://github.com/HomeOfVapourSynthEvolution/VapourSynth-Retinex.git
cd VapourSynth-Retinex
meson build && ninja -C build && ninja -C build install

# sangnom
cd ~/_opaencoder_deps
git clone https://github.com/dubhater/vapoursynth-sangnom.git
cd vapoursynth-sangnom
meson build && ninja -C build && ninja -C build install

# scxvid
cd ~/_opaencoder_deps
git clone https://github.com/dubhater/vapoursynth-scxvid.git
cd vapoursynth-scxvid
./autogen.sh && ./configure --libdir=/usr/lib/vapoursynth && make -j$(nproc) && make install

# tcanny
cd ~/_opaencoder_deps
git clone https://github.com/HomeOfVapourSynthEvolution/VapourSynth-TCanny.git
cd VapourSynth-TCanny
meson build -Dopencl=false && ninja -C build && ninja -C build install

# tcomb
cd ~/_opaencoder_deps
git clone https://github.com/dubhater/vapoursynth-tcomb.git
cd vapoursynth-tcomb
meson build && ninja -C build && ninja -C build install

# tdeintmod
cd ~/_opaencoder_deps
git clone https://github.com/HomeOfVapourSynthEvolution/VapourSynth-TDeintMod.git
cd VapourSynth-TDeintMod
meson build && ninja -C build && ninja -C build install

# add your own vapoursynth plugins here

# install vapoursynth helper scripts
cd ~/_opaencoder_deps
export PYTHON_SITE_PATH=`python -c 'import site; print(site.getsitepackages()[0])'`
git clone https://github.com/HomeOfVapourSynthEvolution/havsfunc.git
cp ~/_opaencoder_deps/havsfunc/havsfunc.py ${PYTHON_SITE_PATH}
git clone https://github.com/Irrational-Encoding-Wizardry/fvsfunc.git
cp ~/_opaencoder_deps/fvsfunc/fvsfunc.py ${PYTHON_SITE_PATH}
git clone https://github.com/Irrational-Encoding-Wizardry/kagefunc.git
cp ~/_opaencoder_deps/kagefunc/kagefunc.py ${PYTHON_SITE_PATH}
pip3 install git+https://github.com/Irrational-Encoding-Wizardry/lvsfunc.git
