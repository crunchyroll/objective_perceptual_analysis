#!/bin/sh

#
# generate a script of tests to run
#

testnum="000"
if [ "$1" != "" ]; then
    testnum="$1"
fi
b=1000

printf '#!/bin/sh'
printf "\n\n"
printf 'bin/encode.py \\
        -m vmaf,psnr \\
        -n tests/test'
printf $testnum
printf ' \\
        -p '
printf "%d" $(nproc)
printf ' -t "\\'

while [ $b -le 8000 ]; do
    printf "\n%05dX264H264|FFmpeg/ffmpeg|twopass|S|-pix_fmt|yuv420p|-f|mp4|-movflags|+faststart|-profile:v|high|-preset|slow|-vcodec|libx264|-bf|0|-refs|4|-b:v|%dk|-maxrate:v|%0.0fk|-bufsize:v|%0.0fk|-minrate:v|%dk|-tune|animation|-x264opts|rc-lookahead=48:keyint=96|-keyint_min|48|-g|96|-force_key_frames|expr:eq(mod(n,48),0)|-hide_banner|-nostats;\\" $b $b $(echo "$b * 1.5" | bc -l) $(echo "$b * 3" | bc -l) $b
    printf "\n%05dAOMAV1|FFmpeg/ffmpeg|twopass|S|-pix_fmt|yuv420p|-f|mp4|-movflags|+faststart|-vcodec|libaom-av1|-cpu-used|1|-strict|experimental|-b:v|%dk|-maxrate:v|%0.0fk|-bufsize:v|%0.0fk|-minrate:v|%dk|-keyint_min|48|-g|48|-hide_banner|-nostats|-row-mt|1;\\" $b $b $(echo "$b * 1.5" | bc -l) $(echo "$b * 3" | bc -l) $b
    printf "\n%05dRAV1EAV1|FFmpeg/ffmpeg|twopass|S|-pix_fmt|yuv420p|-f|mp4|-movflags|+faststart|-vcodec|librav1e|-speed|6|-b:v|%dk|-keyint_min|48|-g|48|-hide_banner|-nostats;\\" $b $b
    printf "\n%05dSVTAV1|FFmpeg/ffmpeg|vbr||-pix_fmt|yuv420p|-f|mp4|-movflags|+faststart|-vcodec|libsvt_av1|-preset|4|-b:v|%dk|-maxrate:v|%0.0fk|-bufsize:v|%0.0fk|-minrate:v|%dk|-rc|vbr|-sc_detection|0|-keyint_min|48|-g|48|-hide_banner|-nostats;\\" $b $b $(echo "$b * 1.5" | bc -l) $(echo "$b * 3" | bc -l) $b
    printf "\n%05dVPXVP9|FFmpeg/ffmpeg|twopass|S|-pix_fmt|yuv420p|-f|mp4|-movflags|+faststart|-vcodec|libvpx-vp9|-speed|1|-b:v|%dk|-maxrate:v|%0.0fk|-bufsize:v|%0.0fk|-minrate:v|%dk|-keyint_min|48|-g|48|-hide_banner|-nostats|-row-mt|1;\\" $b $b $(echo "$b * 1.5" | bc -l) $(echo "$b * 3" | bc -l) $b
    b=$(expr $b + 1000)
done

printf "\n"
printf '"'
printf "\n"
