
all: reference

reference:
	 g++ reference.cpp -std=c++11 -lopencv_core -lopencv_highgui -lopencv_img_hash -lopencv_imgproc -lopencv_imgcodecs -o reference

x264lib:
	cd x264 && \
	./configure --prefix=/usr --disable-lavf --enable-static --enable-shared && \
	make -j8 && \
	sudo make install && \
	sudo ldconfig

ffmpeg:
	cd FFmpeg && \
	make clean && \
	./configure --prefix=/usr --enable-libx264 --enable-gpl --enable-libopencv && \
	make -j8
