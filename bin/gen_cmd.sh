b=500
while [ $b -le 16000 ]; do
    printf "\n%05dH264|FFmpeg/ffmpeg|twopass|-pix_fmt|yuv420p|-f|mp4|-movflags|+faststart|-profile:v|high|-preset|slow|-vcodec|libx264|-bf|0|-refs|4|-b:v|%dk|-maxrate:v|%0.0fk|-bufsize:v|%0.0fk|-minrate:v|%dk|-tune|animation|-x264opts|rc-lookahead=48:keyint=96|-keyint_min|48|-g|96|-force_key_frames|expr:eq(mod(n,48),0)|-hide_banner|-nostdin|-copyts|-start_at_zero|-max_delay|0|-max_muxing_queue_size|1024|-nostats;\\" $b $b $(echo "$b * 1.5" | bc -l) $(echo "$b * 3" | bc -l) $b
    printf "\n%05dVP9|FFmpeg/ffmpeg|twopass|-pix_fmt|yuv420p|-f|mp4|-movflags|+faststart|-profile:v|high|-preset|slow|-vcodec|libvpx-vp9|-speed|2|-b:v|%dk|-maxrate:v|%0.0fk|-bufsize:v|%0.0fk|-minrate:v|%dk|-keyint_min|48|-g|48|-hide_banner|-nostdin|-copyts|-start_at_zero|-max_delay|0|-max_muxing_queue_size|1024|-nostats|-row-mt|1;\\" $b $b $(echo "$b * 1.5" | bc -l) $(echo "$b * 3" | bc -l) $b
    b=$(expr $b + 500)
done
