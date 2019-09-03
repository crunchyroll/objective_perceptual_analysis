#
# Chris Kennedy - Perceptual Encoder Makefile
#
# This works on CentOS 7 and Mac OS X
#

UNAME_S := $(shell uname -s)

all: reference
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

ffmpegbin:
	cd FFmpeg && \
	./configure --prefix=/usr --enable-libx264 --enable-gpl --enable-libopencv && \
	make clean && \
	make -j8 

install:
	cd FFmpeg && \
	sudo make install

