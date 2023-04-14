# Helper Scripts
A set of helper scripts designed to work in conjunction with the objective_perceptual_analysis tool

## generate-objective-perceptual-analysis-tiers.js
This script generates a list of tiers that can be run through the objective_perceptual_analysis tool to calculate metrics for that tier.

Example run command:
> node generate-objective-perceptual-analysis-tiers.js

Results will look like this:
```
240p00200X264H264|ffmpeg|twopass|S|mp4||240|-pix_fmt|yuv420p|-f|mp4|-movflags|+faststart|-profile:v|high|-preset|slow|-vcodec|libx264|-bf|0|-refs|4|-b:v|200k|-maxrate:v|300k|-bufsize:v|600k|-minrate:v|200k|-tune|animation|-x264opts|rc-lookahead=48:keyint=96|-keyint_min|48|-g|96|-force_key_frames|expr:eq(mod(n,48),0)|-hide_banner|-nostats;\
240p00120X264H264|ffmpeg|twopass|S|mp4||240|-pix_fmt|yuv420p|-f|mp4|-movflags|+faststart|-profile:v|high|-preset|slow|-vcodec|libx264|-bf|0|-refs|4|-b:v|120k|-maxrate:v|180k|-bufsize:v|360k|-minrate:v|120k|-tune|animation|-x264opts|rc-lookahead=48:keyint=96|-keyint_min|48|-g|96|-force_key_frames|expr:eq(mod(n,48),0)|-hide_banner|-nostats;\
...
```

## build-per-title-ladder.js
This script takes in a folder, target vmaf score for top tier, and the desired number of tiers and builds a per-title ladder based off the metrics it finds in that folder.

In order to run you need to first install the npm packages (will need to install npm if not already installed):
> npm i

Example run command: 
> node build-per-title-ladder-csv.js --folder=../../tests/test000/results/ --target=95 --tiersDesired=5

Results will look like this:
```
bitrate,ideal ladder,240,360,480,720,1080
120,,5.778297,4.988284,4.063627,,
200,,10.871521,10.393279,8.083678,,
300,,17.226468,17.951529,15.693013,,
500,,26.987996,30.484075,28.621478,21.335097,12.203873
1000,50.380761,40.999788,49.296895,50.380761,44.335129,32.289643
1500,,48.386209,59.698441,62.471787,59.289839,47.9577
2000,70.150978,52.847373,66.243257,70.150978,68.779799,59.610497
2500,,55.702071,70.794025,75.414619,75.326258,68.026903
3000,80.039061,57.623165,74.053516,79.230803,80.039061,74.402542
3500,,59.004372,76.476479,82.114151,83.566198,79.068612
4000,,59.991882,78.346787,84.352679,86.296918,82.728679
4500,,,79.789811,86.102682,88.478361,85.598901
5000,90.185026,,80.920916,87.502313,90.185026,87.90199
5500,,,,88.634468,91.569519,89.766263
6000,,,,89.533024,92.667164,91.285771
6500,,,,,93.537033,92.530484
7000,,,,,94.244509,93.550486
7500,,,,,94.799134,94.354476
8000,95.024027,,,,95.254355,95.024027
8500,,,,,,95.568996
9000,,,,,,96.022525
9500,,,,,,96.410157
10000,,,,,,96.738205
```
