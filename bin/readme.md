Encoding subjective and objective test harness

bin/encode.py: contains logic to run encoding tests using nuencoder and vqmt
bin/results.py: gather stats and produce reports comparing tests
bin/decode: produce decoded output for test metrics

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
1. build ffmpeg
2. copy mezzanines to ./[test_dir]/mezzanines/
3. execute bin/encode.py (see bin/encode.py -h  for Help Output)
    example: 'bin/encode.py -m psnr,vmaf -n test001 -p 4 -t "test1:FFmpeg/ffmpeg:-vcodec:libx264" -d`
4. execute bin/results.py -n test001 to get results in JSON

Results Json output is CSV compatible in any converter.
Also there is a graph created using gnuplot.

