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
*VMAF, libVPX, libAOM, libRav1e, libx264, libOpenCV build of FFmpeg*
- rav1e support based off of work by Derek Buitenhuis
  https://github.com/dwbuiten/FFmpeg/commit/2172caadfd1d5e8ff0bb16e7c7238338c132ed86

Makefile will run the proper setup scriopt and install mediainfo, opencv, libx264, libvmaf, nasm
git, wget, freetype-devel... Everything should be done for you, although if not report it as a bug.

type: ```make```

Testing: reference program will test that opencv img_hash is working correctly.

```./reference <ref image> <target image>```

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

FFmpeg Commands:

Perceptual Encoding Optimization: (bitrate mode or crf mode)

```./FFmpeg/ffmpeg -i <input file> -vcodec libx264 -b:v 4000k -maxrate:v 4000k -bufsize 4000k -minrate:v 4000k -vf perceptual=hash_type=phash -loglevel debug output.mp4```

```./FFmpeg/ffmpeg -i <input file> -vcodec libx264 -b:v 0 -maxrate:v 4000k -bufsize 4000k -crf 29 -vf perceptual=hash_type=phash -loglevel debug output.mp4```

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
  scd_thresh        <double>     ..FV..... Scene Change Detection Threshold. 0.4 default, 0.0-1.0 (from 0 to 1) (default 0.4)

```

PHQM Scene Detection, frame ranges for each segmented scene with an avg hamming distance score per scene.

```
  # (./FFmpeg/ffmpeg -loglevel warning -i encode.mp4 -i reference.mov -nostats -nostdin \
     -threads 12 -filter_complex [0:v][1:v]img_hash=stats_file=phqm.data -f null -)

[img_hash @ 0x4397900] ImgHashScene: n:1-155 hd_avg:0.3 scd:0.5
[img_hash @ 0x4397900] ImgHashScene: n:156-167 hd_avg:0.0 scd:0.4
[img_hash @ 0x4397900] ImgHashScene: n:168-185 hd_avg:0.2 scd:0.7
[img_hash @ 0x4397900] ImgHashScene: n:186-249 hd_avg:0.2 scd:0.5
[img_hash @ 0x4397900] ImgHashScene: n:250-257 hd_avg:0.2 scd:0.5
[img_hash @ 0x4397900] ImgHashScene: n:258-340 hd_avg:0.1 scd:0.6
[img_hash @ 0x4397900] ImgHashScene: n:341-362 hd_avg:0.4 scd:0.6
[img_hash @ 0x4397900] ImgHashScene: n:363-429 hd_avg:0.5 scd:0.6
[img_hash @ 0x4397900] ImgHashScene: n:430-530 hd_avg:0.1 scd:0.6
[img_hash @ 0x4397900] ImgHashScene: n:531-544 hd_avg:0.1 scd:1.0
[img_hash @ 0x4397900] ImgHashScene: n:545-546 hd_avg:0.0 scd:0.4
[img_hash @ 0x4397900] ImgHashScene: n:547-590 hd_avg:0.3 scd:0.6
[img_hash @ 0x4397900] ImgHashScene: n:591-592 hd_avg:0.5 scd:0.5
[img_hash @ 0x4397900] ImgHashScene: n:593-606 hd_avg:0.1 scd:0.4
[img_hash @ 0x4397900] ImgHashScene: n:607-608 hd_avg:0.0 scd:0.6
[img_hash @ 0x4397900] ImgHashScene: n:609-610 hd_avg:0.0 scd:0.7
[img_hash @ 0x4397900] ImgHashScene: n:611-638 hd_avg:0.2 scd:0.5
[img_hash @ 0x4397900] ImgHashScene: n:639-658 hd_avg:0.4 scd:0.5
[img_hash @ 0x4397900] ImgHashScene: n:659-666 hd_avg:0.1 scd:0.4
[img_hash @ 0x4397900] ImgHashScene: n:667-672 hd_avg:0.3 scd:0.6
[img_hash @ 0x4397900] ImgHashScene: n:673-674 hd_avg:0.5 scd:0.7
[img_hash @ 0x4397900] ImgHashScene: n:675-676 hd_avg:0.0 scd:0.6
[img_hash @ 0x4397900] ImgHashScene: n:677-678 hd_avg:0.0 scd:0.8
[img_hash @ 0x4397900] ImgHashScene: n:679-680 hd_avg:0.0 scd:0.7
[img_hash @ 0x4397900] ImgHashScene: n:681-688 hd_avg:0.1 scd:0.4
[img_hash @ 0x4397900] ImgHashScene: n:689-694 hd_avg:0.0 scd:0.8
[img_hash @ 0x4397900] ImgHashScene: n:695-696 hd_avg:0.0 scd:0.9
[img_hash @ 0x4397900] ImgHashScene: n:697-706 hd_avg:0.4 scd:0.4
[img_hash @ 0x4397900] ImgHashScene: n:707-708 hd_avg:0.5 scd:0.6
[img_hash @ 0x4397900] ImgHashScene: n:709-714 hd_avg:0.7 scd:0.6
[img_hash @ 0x4397900] ImgHashScene: n:715-716 hd_avg:0.0 scd:0.7
[img_hash @ 0x4397900] ImgHashScene: n:717-748 hd_avg:0.2 scd:0.5
[img_hash @ 0x4397900] ImgHashScene: n:749-809 hd_avg:0.3 scd:1.0
[img_hash @ 0x4397900] ImgHashScene: n:810-819 hd_avg:0.4 scd:0.7
[img_hash @ 0x4397900] ImgHashScene: n:820-821 hd_avg:0.5 scd:0.7
[img_hash @ 0x4397900] ImgHashScene: n:822-823 hd_avg:0.0 scd:0.6
[img_hash @ 0x4397900] ImgHashScene: n:824-825 hd_avg:0.5 scd:1.0
[img_hash @ 0x4397900] ImgHashScene: n:826-827 hd_avg:0.0 scd:0.5
[img_hash @ 0x4397900] ImgHashScene: n:828-833 hd_avg:0.0 scd:1.0
[img_hash @ 0x4397900] ImgHashScene: n:834-838 hd_avg:0.4 scd:0.4
[img_hash @ 0x4397900] ImgHashScene: n:839-839 hd_avg:0.0 scd:0.4
[img_hash @ 0x4397900] ImgHashScene: n:840-871 hd_avg:0.3 scd:1.0
[img_hash @ 0x4397900] ImgHashScene: n:872-916 hd_avg:2.6 scd:1.0
[img_hash @ 0x4397900] ImgHashScene: n:917-962 hd_avg:0.2 scd:0.6
[Parsed_img_hash_0 @ 0x43995c0] PHQM average:0.337688 PSNR y:47.905592 u:50.652101 v:50.989231 average:48.677526 min:42.160245 max:59.821908
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
