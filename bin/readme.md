Encoding subjective and objective test harness

bin/encode.py: contains logic to run encoding tests using FFmpeg/ffmpeg
bin/results.py: gather stats and produce reports comparing tests
bin/decode: produce decoded output for test metrics

scripts/run_example.sh: example of a command line with many tests
scripts/clip_videos.sh: clipping video helper script to create in/out points
scripts/gen_cmd.sh: help create multiple command lines of incrementing bitrates

General usage:
- setup FFmpeg for perceptual hash per title encoding
- copy mezzanines to test into ./[test_dir]/mezzanines/ directory
- execute ./bin/encode.py -n test_dir ... (-h for arguments)
- execute ./bin/results.py -n test_dir

Directories:
* [test_dir]/mezzanines/   put video files in this directory to use for analysis and testing.
* [test_dir]/encodes/      contains encoding variants and .json stats files with
                            encoding parameters.
* [test_dir]/results/      contains metric output (vmaf, msssim, psnr).

Example steps:
1. build ffmpeg following instructions in base readme file
2. copy mezzanines to ./[test_dir]/mezzanines/
3. execute bin/encode.py (see bin/encode.py -h  for Help Output)
    example: (multiple tests can be separated by commas)
    
   ```bin/encode.py -m psnr,vmaf -n test001 -p 4 \
   -t "test1|ffmpeg|twopass|S|mp4|-vcodec|libx264|-vf|perceptual|-b:v|4000k|-maxrate:v|4000k|-bufsize|6000k" -d -o
   ```
        
    The PATH environment is set to include ./FFmpeg/ so it will use the custom one automatically.
    Format - ```Label|FFmpegBin|RateControl|Flags|Format|arg|arg;Label|FFmpegBin|RC|Flgs|Fmt|arg|arg;...```
        - multiple sets of encode tests separted by semi colons with each FFmpeg
        arg separated by pipes, with a label, binary path, and rate control method.
        - FLAGS:
        -   S=segmented/parallel encoding mode
        -   F=force mezzanine fps (use -r FPS when encoding)
        - Encoders:
        -   ffmpeg - supports FFmpeg/ffmpeg build via 'ffmpeg'
        -   SvtAv1EncApp - if given as an encoder then it is used instead of ffmpeg
    
format output supported:
   
    - webm
    - mp4
    
ratecontrol options:
   
    - twopass (implemented)
    - crf_NN
    - perceptual_crf_NN
    - perceptual_abr
    - abr
    
Encoding Features / Research items:

    - Parallel / Segmented encoding (especially for AV1)
    - Image Hash x264 Perceptual encode optimization (WIP, help if you want)
    - Perceptual Hash metric for analysis
    - AV1 Encoding
    - VP9 Encoding
    - H.264 Encoding

4. execute ```bin/results.py -n test001``` to get results

Results Json ```stats.json``` output is CSV compatible in any converter.
Also there is a graph ```stats.jpg``` created using gnuplot and ```stats.csv```.

