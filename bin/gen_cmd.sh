b=500
while [ $b -le 16000 ]; do
    b=$(expr $b + 500)
    printf "\n%05d|FFmpeg/ffmpeg|twopass|-pix_fmt|yuv420p|-f|mp4|-movflags|+faststart|-profile:v|high|-preset|slow|-vcodec|libx264|-bf|0|-refs|4|-b:v|%dk|-maxrate:v|%dk|-bufsize:v|%dk|-minrate:v|%dk|-tune|animation|-x264opts|rc-lookahead=48:keyint=96|-keyint_min|48|-g|96|-force_key_frames|expr:eq(mod(n,48),0)|-hide_banner|-nostdin|-copyts|-start_at_zero|-max_delay|0|-max_muxing_queue_size|1024|-nostats;\\" $b $b $(($b*2)) $(($b*3)) $b
done
