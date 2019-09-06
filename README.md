Perceptual Hash Per Title Encoder && Quality Metric

Use OpenCV img_hash frame comparisons in FFmpeg libavfilter for per title encoding / Perceptual Quality comparisons

Documentation on OpenCV img_hash: https://docs.opencv.org/trunk/d4/d93/group__img__hash.html

This will use perceptual hashes from OpenCV's img_hash module which includes PHash
and it the main algorithm used. Each video frame is compared to the last video frame
then a hamming distance is derived from the two hashes. This values shows the perceptual
similarity of the two images. The hamming distance is used to vary the encoders bitrate
or CRF level. Currently only X264 is supported in this implementation. 

Everything can be easily setup via setup.sh, it will install what is necessary
for the most part. Please report back any issues so this can be improved for edge cases.

*Currenty works only on CentOS 7*

Setup everything, setup.sh will install opencv, libx264
you will need wget, git installed beforehand.

./setup.sh

Testing: reference program will test that opencv img_hash is working correctly.

./reference

This uses an FFmpeg with an extra video filter which uses OpenCV to
compute hamming distance values from each frames hash vs. the previous
frames hash. 

https://github.com/bitbytebit-cr/FFmpeg_perceptual

FFmpeg Commands:

Perceptual Encoding Optimization:

```./ffmpeg -i <intput file> -vcodec libx264 -b:v 4000k -vf perceptual=hash_type=phash -loglevel debug output.mp4```

```
perceptual AVOptions:
  hash_type         <string>     ..FV..... options: phash, colormoment, average (default "phash")
  score_multiplier  <double>     ..FV..... multiply the hamming score result by this value. 2.0 by default (from 0 to 100) (default 2)
  score_factor      <double>     ..FV..... factor to decrease compression, multiplier for bitrate, range for crf. 2.0 default (from 0 to 1000) (default 2)
```

Perceptual Hash Quality Metric: (output a stats file with psnr/mse/phqm (perceptual hash quality metric)

```./FFmpeg/ffmpeg -i <encode> -i <refvideo> -filter_complex "[0:v][1:v]img_hash=hash_type=colormoment:stats_file=stats.log" -f null -```
```
img_hash AVOptions:
  stats_file        <string>     ..FV..... Set file where to store per-frame difference information
  f                 <string>     ..FV..... Set file where to store per-frame difference information
  stats_version     <int>        ..FV..... Set the format version for the stats file. (from 1 to 2) (default 1)
  output_max        <boolean>    ..FV..... Add raw stats (max values) to the output log. (default false)
  hash_type         <string>     ..FV..... options: phash, colormoment, average (default "phash")

```

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
