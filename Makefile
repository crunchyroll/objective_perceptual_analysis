#
# Chris Kennedy - Perceptual Encoder Makefile
#
# This works on CentOS 7 and Mac OS X
#

UNAME_S := $(shell uname -s)

all: setup reference

setup:
	./setup.sh

reference:
	 g++ reference.cpp -std=c++11 -lopencv_core -lopencv_highgui -lopencv_img_hash -lopencv_imgproc -lopencv_imgcodecs -o reference

x264lib:
	cd x264 && \
	./configure --prefix=/usr --disable-lavf --enable-static --enable-shared && \
	make clean && \
	make -j8 && \
	sudo make install && \
	sudo ldconfig

vpxlib:
	cd libvpx/build/ && \
	../configure --prefix=/usr && \
	make -j8 && \
	sudo make install

aomlib:
	rm -rf aom/aombuild && \
	mkdir aom/aombuild && \
	cd aom/aombuild/ && \
	cmake3 \
		-DCMAKE_INSTALL_PREFIX=/usr \
		-DCMAKE_INSTALL_LIBDIR=lib \
		-DBUILD_SHARED_LIBS=True \
		-DCMAKE_BUILD_TYPE=Release ../ && \
	make -j8 && \
	sudo make install

svtav1lib:
	cd SVT-AV1/Build && \
	cmake .. -G"Unix Makefiles" \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_CXX_FLAGS="$$CXXFLAGS" \
	-DCMAKE_C_FLAGS="$$CFLAGS" \
	-DCMAKE_CXX_COMPILER=/usr/local/bin/g++ \
	-DCMAKE_CC_COMPILER=/usr/local/bin/gcc && \
	make -j1 && \
	sudo make install

rav1elib:
	cd rav1e && \
	cargo build --release && \
	sudo cargo cinstall --release

vmaflib:
	cd vmaf && \
        make -j8 && \
        sudo make install

ffmpegbin:
	cd FFmpeg && \
	./configure --prefix=/usr --enable-libx264 --enable-libvpx --enable-gpl --enable-libopencv --enable-version3 --enable-libvmaf --enable-libfreetype --enable-fontconfig --enable-libass --enable-libaom --enable-librav1e && \
	make clean && \
	make -j8

install:
	cd FFmpeg && \
	sudo make install

