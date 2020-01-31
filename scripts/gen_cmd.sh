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
        -m vmaf,psnr,phqm,ssim \\
        -n tests/test'
printf $testnum
printf ' \\
        -p '
printf "%d" $(nproc)
printf ' -t "\\'

while [ $b -le 8000 ]; do
    printf "\n%05dX264H264|ffmpeg|twopass|S|mp4|-pix_fmt|yuv420p|-f|mp4|-movflags|+faststart|-profile:v|high|-preset|slow|-vcodec|libx264|-bf|0|-refs|4|-b:v|%dk|-maxrate:v|%0.0fk|-bufsize:v|%0.0fk|-minrate:v|%dk|-tune|animation|-x264opts|rc-lookahead=48:keyint=96|-keyint_min|48|-g|96|-force_key_frames|expr:eq(mod(n,48),0)|-hide_banner|-nostats;\\" $b $b $(echo "$b * 1.5" | bc -l) $(echo "$b * 3" | bc -l) $b
    if [ $b -ge 7000 ]; then
        b=$(expr $b + 1000)
        continue
    fi
    printf "\n%05dAOMAV1|ffmpeg|twopass|S|mp4|-pix_fmt|yuv420p|-f|mp4|-movflags|+faststart|-vcodec|libaom-av1|-cpu-used|1|-strict|experimental|-b:v|%dk|-maxrate:v|%0.0fk|-bufsize:v|%0.0fk|-minrate:v|%dk|-keyint_min|48|-g|48|-hide_banner|-nostats|-row-mt|1;\\" $b $b $(echo "$b * 1.5" | bc -l) $(echo "$b * 3" | bc -l) $b
    printf "\n%05dRAV1EAV1|ffmpeg|twopass|S|mp4|-pix_fmt|yuv420p|-f|mp4|-movflags|+faststart|-vcodec|librav1e|-speed|3|-b:v|%dk|-keyint_min|48|-g|48|-hide_banner|-nostats;\\" $b $b
    # ffmpeg patch seems to have bugs
    #printf "\n%05dSVTAV1|ffmpeg|vbr||mp4|-pix_fmt|yuv420p|-f|mp4|-movflags|+faststart|-vcodec|libsvt_av1|-preset|3|-b:v|%dk|-maxrate:v|%0.0fk|-bufsize:v|%0.0fk|-minrate:v|%dk|-rc|vbr|-keyint_min|48|-g|48|-hide_banner|-nostats;\\" $b $b $(echo "$b * 1.5" | bc -l) $(echo "$b * 3" | bc -l) $b

    printf "\n%05dSVTAV1|SvtAv1EncApp|vbr||mp4|-enc-mode|3|-film-grain|0|-adaptive-quantization|0|-rc|1|-tbr|%d|-intra-period|48|-irefresh-type|1;\\" $b $b

    # not enabled by default, MacOS doesn't dig it
    #printf "\n%05dSVTVP9|SvtVp9EncApp|vbr||mp4|-enc-mode|0|-tune|2|-rc|1|-tbr|%d|-vbv-maxrate|%0.0f|-vbv-bufsize|%0.0f|-intra-period|48|-irefresh-type|2;\\" $b $(echo "$b * 1000" | bc -l) $(echo "$b * 1000 * 1.5" | bc -l) $(echo "$b * 1000 * 3" | bc -l)

    # ffmpeg patch seems to have bugs
    #printf "\n%05dSVTVP9|ffmpeg|vbr||mp4|-pix_fmt|yuv420p|-f|mp4|-vcodec|libsvt_vp9|-preset|5|-tune|2|-b:v|%dk|-maxrate:v|%0.0fk|-bufsize:v|%0.0fk|-minrate:v|%dk|-rc|vbr|-keyint_min|48|-g|48|-hide_banner|-nostats;\\" $b $b $(echo "$b * 1.5" | bc -l) $(echo "$b * 3" | bc -l) $b

    printf "\n%05dVPXVP9|ffmpeg|twopass|S|mp4|-pix_fmt|yuv420p|-f|mp4|-movflags|+faststart|-vcodec|libvpx-vp9|-speed|0|-b:v|%dk|-maxrate:v|%0.0fk|-bufsize:v|%0.0fk|-minrate:v|%dk|-g|48|-hide_banner|-nostats|-row-mt|1|-tune-content|0|-tile-columns|1|-aq-mode|0|-overshoot-pct|0|-undershoot-pct|0|-auto-alt-ref|1;\\" $b $b $(echo "$b * 1.5" | bc -l) $(echo "$b * 3" | bc -l) $b
    b=$(expr $b + 1000)
done

printf "\n"
printf '"'
printf "\n"
