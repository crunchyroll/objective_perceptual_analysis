#perceptual_hash_encoder
Use an OpenCV img_hash based FFmpeg libavfilter for per title encoding

Setup everything, setup.sh will install opencv, libx264
you will need wget, git installed beforehand.

./setup.sh

Testing: reference program will test that opencv img_hash is working correctly.

./reference

This uses an FFmpeg with an extra video filter which uses OpenCV to
compute hamming distance values from each frames hash vs. the previous
frames hash. 

https://github.com/bitbytebit-cr/FFmpeg_perceptual

FFmpeg Command to test:
- ./ffmpeg -i <intput file> -vcodec libx264 -b:v 4000k -vf perceptual=hash_type=phash -loglevel debug output.mp4

This is implementing a Patent by Christopher Kennedy @ Ellation / Crunchyroll:

Patent for https://patents.justia.com/patent/10244234
Adaptive compression rate control

Nov 18, 2016

Disclosed by way of example embodiments are a system and a computer implemented
method for adaptively encoding a video by changing compression rates for
different frames of the video. In one aspect, two frames of a video are
compared to determine a compression rate for compressing one of the two frames.
Hash images may be generated for corresponding frames for the comparison.
By comparing two hash images, a number of stationary objects and a number of
moving objects in the two frames may be determined. Moreover, a compression rate
may be determined according to the number of stationary objects and
the number of moving objects.

Patent number: 10244234 Filed: Nov 18, 2016 Date of Patent: Mar 26, 2019 Patent Publication Number: 20170150145
Assignee: Ellation, Inc. (San Francisco, CA) Inventor: Chris Kennedy (Alameda, CA) Primary Examiner: Dramos Kalapodas
Application Number: 15/356,510
