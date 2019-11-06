Objective Perceptual Analysis - Video Karma Predictor

This is a kit for testing codecs objectively through FFmpeg.
It employs VMAF, SSIM, PSNR and also a Perceptual Hash metric.
Multiple encoding tests can be ran comparing the encoders and
the encodings, encoding techniques. The metrics and test harness
allow quick feedback to test theories and new code in FFmpeg.
There's objective metrics, graphs and easy comparisons historically.

Use OpenCV img_hash frame comparisons in FFmpeg libavfilter for per title encoding / Perceptual Quality comparisons

Documentation on OpenCV img_hash: https://docs.opencv.org/trunk/d4/d93/group__img__hash.html

This will use perceptual hashes from OpenCV's img_hash module which includes PHash
and it the main algorithm used. Each video frame is compared to the last video frame
then a hamming distance is derived from the two hashes. This values shows the perceptual
similarity of the two images. The hamming distance is used to vary the encoders bitrate
or CRF level. Currently only X264 is supported in this implementation. 

Also research via bin/encode.py and bin/results.py script:

- Parallel Encoding / can set per test for comparisons
- Quality both Objective and setup for Subjective tests
- Easy encoding tests for H.254, VP9 and AV1
- Perceptual Hash research with encoding decisions and metrics
- Simple Objective metrics calculated
- Frame images and metrics burn in per frame via SRT
- Scene segmentation and analysis with objective metrics

Everything can be easily setup via setup.sh, it will install what is necessary
for the most part. Please report back any issues so this can be improved for edge cases.

See the bin/readme.md file for information on bin/encode.py and bin/results.py.
See the scripts/readme.md file for information on setting up tests.

*Currenty works on CentOS 7 and Mac OS X*
*VMAF, libVPX, libAOM, libRav1e, svt-av1, libx264, libOpenCV build of FFmpeg*
- rav1e support based off of work by Derek Buitenhuis
  https://github.com/dwbuiten/FFmpeg

*Dockerfile setup: Easy and safest*

```
type: make docker

Example using the docker image:
- docker run --rm -v `pwd`/tests:/opaencoder/tests opaencoder sh scripts/run_example.sh
- docker run --rm -v `pwd`/tests:/opaencoder/tests opaencoder bin/encode.py -m vmaf,psnr\
        -n tests/test000 -p 2 -t "01000X264H264|ffmpeg|twopass|S|mp4|-pix_fmt|yuv420p|-f|mp4|-movflags|+faststart|-profile:v|high|-preset|slow|-vcodec|libx264|-bf|0|-refs|4|-b:v|1000k|-maxrate:v|1500k|-bufsize:v|3000k|-minrate:v|1000k|-tune|animation|-x264opts|rc-lookahead=48:keyint=96|-keyint_min|48|-g|96|-force_key_frames|expr:eq(mod(n,48),0)|-hide_banner|-nostats"

```

Makefile will run the proper setup script and install mediainfo, opencv, libx264, libvmaf, nasm
git, wget, freetype-devel... Everything should be done for you, although if not report it as a bug.
*Warning: Scripts will install / alter system packages via Sudo. Please keep this in mind*

type: ```make```

This uses an FFmpeg with an extra video filter which uses OpenCV to
compute hamming distance values from each frames hash vs. the previous
frames hash. 

There is a ffmpeg_modifications.diff patch included...

(this is done for you via the make command which runs the proper setup* script)

```
    git clone https://git.ffmpeg.org/ffmpeg.git FFmpeg
    cd FFmpeg
    git checkout remotes/origin/release/4.2
    cat ../ffmpeg_modifications.diff | patch -p1
```

You can run tests using the bin/encode.py script. See the /bin/readme.md for more
details.

FFmpeg Commands:

Perceptual Hash Quality Metric: (output a stats file with psnr/mse/phqm (perceptual hash quality metric)

```./FFmpeg/ffmpeg -i <encode> -i <refvideo> -filter_complex "[0:v][1:v]phqm=hash_type=phash:stats_file=stats.log" -f null -```
```
phqm AVOptions:
  stats_file        <string>     ..FV..... Set file where to store per-frame difference information.
  f                 <string>     ..FV..... Set file where to store per-frame difference information.
  scd_thresh        <double>     ..FV..... Scene Change Detection Threshold. (from 0 to 1) (default 0.5)
  hash_type         <int>        ..FV..... Type of Image Hash to use from OpenCV. (from 0 to 6) (default phash)
     average                      ..FV..... Average Hash
     blockmean1                   ..FV..... Block Mean Hash 1
     blockmean2                   ..FV..... Block Mean Hash 2
     colormoment                  ..FV..... Color Moment Hash
     marrhildreth                 ..FV..... Marr Hildreth Hash
     phash                        ..FV..... Perceptual Hash (PHash)
     radialvariance               ..FV..... Radial Variance Hash
```

PHQM Scene Detection, frame ranges for each segmented scene with an avg hamming distance score per scene.

```
  # (./FFmpeg/ffmpeg -loglevel warning -i encode.mp4 -i reference.mov -nostats -nostdin \
     -threads 12 -filter_complex [0:v][1:v]phqm=stats_file=phqm.data -f null -)

[phqm @ 0x40def00] ImgHashScene: n:1-231 hd_avg:0.861 hd_min:0.000 hd_max:6.000 scd:0.80
[phqm @ 0x40def00] ImgHashScene: n:232-491 hd_avg:0.265 hd_min:0.000 hd_max:2.000 scd:0.57
[phqm @ 0x40def00] ImgHashScene: n:492-541 hd_avg:0.340 hd_min:0.000 hd_max:2.000 scd:0.57
[phqm @ 0x40def00] ImgHashScene: n:542-658 hd_avg:0.350 hd_min:0.000 hd_max:2.000 scd:0.82
[phqm @ 0x40def00] ImgHashScene: n:659-708 hd_avg:0.420 hd_min:0.000 hd_max:2.000 scd:0.92
[phqm @ 0x40def00] ImgHashScene: n:709-1057 hd_avg:1.009 hd_min:0.000 hd_max:6.000 scd:0.51
[phqm @ 0x40def00] ImgHashScene: n:1058-1266 hd_avg:0.708 hd_min:0.000 hd_max:4.000 scd:0.59
[Parsed_phqm_0 @ 0x40f1340] PHQM average:0.601282 min:0.000000 max:6.000000
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
