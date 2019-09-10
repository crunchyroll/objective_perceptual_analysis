Encoding subjective and objective test harness

bin/encode.py: contains logic to run encoding tests using nuencoder and vqmt
bin/results.py: gather stats and produce reports comparing tests
bin/decode: produce decoded output for test metrics

bin/run_example.sh: example of a command line with many tests
bin/clip_videos.sh: clipping video helper script to create in/out points
bin/gen_cmd.sh: help create multiple command lines of incrementing bitrates

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
    
   ```'bin/encode.py -m psnr,vmaf -n test001 -p 4 \   
   -t "test1|FFmpeg/ffmpeg|twopass|-vcodec|libx264|-vf|perceptual|-b:v|4000k|-maxrate:v|4000k|-bufsize|6000k" -d -o'
   ```
        
    Format - ```Label|FFmpegBin|RateControl|arg|arg;Label|FFmpegBin|RC|arg|arg;...```
        - multiple sets of encode tests separted by semi colons with each FFmpeg
        arg separated by pipes, with a label, binary path, and rate control method.
    
    ratecontrol options:
    - twopass (implemented)
    (below are not implemented, add them to the cmdline for ffmpeg)
    - crf_NN
    - perceptual_crf_NN
    - perceptual_abr
    - abr
    
4. execute ```bin/results.py -n test001``` to get results

Results Json ```stats.json``` output is CSV compatible in any converter.
Also there is a graph ```stats.jpg``` created using gnuplot and ```stats.dat```.

