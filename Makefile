
all: reference

reference:
	 g++ reference.cpp -std=c++11 -lopencv_core -lopencv_highgui -lopencv_img_hash -lopencv_imgproc -lopencv_imgcodecs -o reference

