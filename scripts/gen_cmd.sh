#!/bin/sh

#
# generate a script of tests to run
#

testnum="000"
if [ "$1" != "" ]; then
    testnum="$1"
fi
#SCALE_1080_BICUBIC="scale=h=1080:w=-1:flags=bicubic"

printf '#!/bin/sh'
printf "\n\n"
printf 'bin/encode.py \\
        -m vmaf,psnr,phqm,ssim \\
        -n tests/test'
printf $testnum
printf ' \\
        -p '
printf "%d" $(nproc)
printf ' -t "\\'

for resolution in 1080 720 480; do
    b=1000
    max=6000
    inc=1000
    totalmax=8000
    if [ $resolution == 720 ]; then
        b=500
        max=2000
        totalmax=4000
        inc=250
    elif [ $resolution == 480 ]; then
        b=250
        max=1000
        totalmax=1500
        inc=250
    fi
    while [ $b -le $totalmax ]; do
        printf "\n%04dp%05dkX264H264|ffmpeg|twopass|S|mp4||%d|-pix_fmt|yuv420p|-f|mp4|-movflags|+faststart|-profile:v|high|-preset|slow|-vcodec|libx264|-bf|0|-refs|4|-b:v|%dk|-maxrate:v|%0.0fk|-bufsize:v|%0.0fk|-minrate:v|%dk|-tune|animation|-x264opts|rc-lookahead=48:keyint=96|-keyint_min|48|-g|96|-force_key_frames|expr:eq(mod(n,48),0)|-hide_banner|-nostats;\\" $resolution $b $resolution $b $(echo "$b * 1.5" | bc -l) $(echo "$b * 3" | bc -l) $b
        if [ $b -ge $max ]; then
            b=$(expr $b + $inc)
            continue
        fi
        printf "\n%04dp%05dkAOMAV1|ffmpeg|twopass|S|mp4||%d|-pix_fmt|yuv420p|-f|mp4|-movflags|+faststart|-vcodec|libaom-av1|-cpu-used|4|-strict|experimental|-b:v|%dk|-maxrate:v|%0.0fk|-bufsize:v|%0.0fk|-minrate:v|%dk|-keyint_min|48|-g|48|-hide_banner|-nostats|-row-mt|1;\\" $resolution $b $resolution $b $(echo "$b * 1.5" | bc -l) $(echo "$b * 3" | bc -l) $b
        printf "\n%05dRAV1EAV1|ffmpeg|twopass|S|mp4||%d|-pix_fmt|yuv420p|-f|mp4|-movflags|+faststart|-vcodec|librav1e|-speed|6|-b:v|%dk|-keyint_min|48|-g|48|-hide_banner|-nostats;\\" $resolution $b $resolution $b
        # ffmpeg patch seems to have bugs
        printf "\n%04dp%05dSVTAV1|ffmpeg|vbr||mp4||%d|-pix_fmt|yuv420p|-f|mp4|-movflags|+faststart|-vcodec|libsvt_av1|-preset|3|-b:v|%dk|-maxrate:v|%0.0fk|-bufsize:v|%0.0fk|-minrate:v|%dk|-rc|vbr|-keyint_min|48|-g|48|-hide_banner|-nostats;\\" $resolution $b $resolution $b $(echo "$b * 1.5" | bc -l) $(echo "$b * 3" | bc -l) $b

        printf "\n%04dp%05dkVPXVP9|ffmpeg|twopass|S|mp4||%d|-pix_fmt|yuv420p|-f|mp4|-movflags|+faststart|-vcodec|libvpx-vp9|-speed|0|-b:v|%dk|-maxrate:v|%0.0fk|-bufsize:v|%0.0fk|-minrate:v|%dk|-g|48|-hide_banner|-nostats|-row-mt|1|-tune-content|0|-tile-columns|1|-aq-mode|0|-overshoot-pct|0|-undershoot-pct|0|-auto-alt-ref|1;\\" $resolution $b $resolution $b $(echo "$b * 1.5" | bc -l) $(echo "$b * 3" | bc -l) $b
        b=$(expr $b + $inc)
    done
done

printf "\n"
printf '"'
printf "\n"
