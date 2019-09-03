Encoding subjective and objective test harness

bin/encode.py: contains logic to run encoding tests using nuencoder and vqmt
bin/results.py: gather stats and produce reports comparing tests
bin/decode: produce decoded output for test metrics

General usage:
- setup FFmpeg for perceptual hash per title encoding
- copy mezzanines to test into ./mezzanines/ directory
- execute ./bin/encode.py
- execute ./bin/results.py

Directories:
* mezzanines/   put video files in this directory to use for analysis and testing.
* encodes/      contains encoding variants and .json stats files with
                    encoding parameters.
* results/      contains metric output (vmaf, msssim, psnr).

Example steps:
1. build ffmpeg
2. copy mezzanines to ./mezzanines/
3. execute bin/encode.py
4. execute bin/results.py to get results in JSON

Results output is CSV compatible in any converter.

