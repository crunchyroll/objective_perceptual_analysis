// Tutorial and code from
// https://qtandopencv.blogspot.com/2016/06/introduction-to-image-hash-module-of.html


#include <opencv2/core.hpp>
#include <opencv2/core/ocl.hpp>
#include <opencv2/highgui.hpp>
#include <opencv2/img_hash.hpp>
#include <opencv2/imgproc.hpp>

#include <iostream>

using namespace cv;
using namespace cv::img_hash;
using namespace std;

void computeHash(cv::Ptr<cv::img_hash::ImgHashBase> algo, char *ref, char *enc)
{
    cv::Mat const input = cv::imread(ref);
    cv::Mat const target = cv::imread(enc);
    
    cv::Mat inHash; //hash of input image
    cv::Mat targetHash; //hash of target image

    //comupte hash of input and target
    algo->compute(input, inHash);
    algo->compute(target, targetHash);
    //Compare the similarity of inHash and targetHash
    //recommended thresholds are written in the header files
    //of every classes
    double const mismatch = algo->compare(inHash, targetHash);
    std::cout<<mismatch<<std::endl;
}

int main(int argc, char **argv)
{
    //disable opencl acceleration may boost up speed of img_hash
    //however, in this post I do not disable the optimization of opencl    
    //cv::ocl::setUseOpenCL(false);
    //
    if (argc <= 1) {
        printf("Usage: reference <image_reference> <encoded_image>\n");
        exit(1);
    }

    computeHash(img_hash::AverageHash::create(), argv[1], argv[2]);
    computeHash(img_hash::PHash::create(), argv[1], argv[2]);
    computeHash(img_hash::MarrHildrethHash::create(), argv[1], argv[2]);
    computeHash(img_hash::RadialVarianceHash::create(), argv[1], argv[2]);
    //BlockMeanHash support mode 0 and mode 1, they associate to 
    //mode 1 and mode 2 of PHash library
    computeHash(img_hash::BlockMeanHash::create(0), argv[1], argv[2]);
    computeHash(img_hash::BlockMeanHash::create(1), argv[1], argv[2]);
    computeHash(img_hash::ColorMomentHash::create(), argv[1], argv[2]);
}

