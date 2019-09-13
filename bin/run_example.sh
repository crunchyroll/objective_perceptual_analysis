bin/encode.py \
        -d \
        -m vmaf,psnr \
        -n test000 \
        -p 12 -t "\
00500H264|FFmpeg/ffmpeg|twopass|-pix_fmt|yuv420p|-f|mp4|-movflags|+faststart|-profile:v|high|-preset|slow|-vcodec|libx264|-bf|0|-refs|4|-b:v|500k|-maxrate:v|750k|-bufsize:v|1500k|-minrate:v|500k|-tune|animation|-x264opts|rc-lookahead=48:keyint=96|-keyint_min|48|-g|96|-force_key_frames|expr:eq(mod(n,48),0)|-hide_banner|-nostdin|-copyts|-start_at_zero|-max_delay|0|-max_muxing_queue_size|1024|-nostats;\
00500VP9|FFmpeg/ffmpeg|twopass|-pix_fmt|yuv420p|-f|mp4|-movflags|+faststart|-profile:v|high|-preset|slow|-vcodec|libvpx-vp9|-speed|2|-b:v|500k|-maxrate:v|750k|-bufsize:v|1500k|-minrate:v|500k|-keyint_min|48|-g|48|-hide_banner|-nostdin|-copyts|-start_at_zero|-max_delay|0|-max_muxing_queue_size|1024|-nostats|-row-mt|1;\
01000H264|FFmpeg/ffmpeg|twopass|-pix_fmt|yuv420p|-f|mp4|-movflags|+faststart|-profile:v|high|-preset|slow|-vcodec|libx264|-bf|0|-refs|4|-b:v|1000k|-maxrate:v|1500k|-bufsize:v|3000k|-minrate:v|1000k|-tune|animation|-x264opts|rc-lookahead=48:keyint=96|-keyint_min|48|-g|96|-force_key_frames|expr:eq(mod(n,48),0)|-hide_banner|-nostdin|-copyts|-start_at_zero|-max_delay|0|-max_muxing_queue_size|1024|-nostats;\
01000VP9|FFmpeg/ffmpeg|twopass|-pix_fmt|yuv420p|-f|mp4|-movflags|+faststart|-profile:v|high|-preset|slow|-vcodec|libvpx-vp9|-speed|2|-b:v|1000k|-maxrate:v|1500k|-bufsize:v|3000k|-minrate:v|1000k|-keyint_min|48|-g|48|-hide_banner|-nostdin|-copyts|-start_at_zero|-max_delay|0|-max_muxing_queue_size|1024|-nostats|-row-mt|1;\
01500H264|FFmpeg/ffmpeg|twopass|-pix_fmt|yuv420p|-f|mp4|-movflags|+faststart|-profile:v|high|-preset|slow|-vcodec|libx264|-bf|0|-refs|4|-b:v|1500k|-maxrate:v|2250k|-bufsize:v|4500k|-minrate:v|1500k|-tune|animation|-x264opts|rc-lookahead=48:keyint=96|-keyint_min|48|-g|96|-force_key_frames|expr:eq(mod(n,48),0)|-hide_banner|-nostdin|-copyts|-start_at_zero|-max_delay|0|-max_muxing_queue_size|1024|-nostats;\
01500VP9|FFmpeg/ffmpeg|twopass|-pix_fmt|yuv420p|-f|mp4|-movflags|+faststart|-profile:v|high|-preset|slow|-vcodec|libvpx-vp9|-speed|2|-b:v|1500k|-maxrate:v|2250k|-bufsize:v|4500k|-minrate:v|1500k|-keyint_min|48|-g|48|-hide_banner|-nostdin|-copyts|-start_at_zero|-max_delay|0|-max_muxing_queue_size|1024|-nostats|-row-mt|1;\
02000H264|FFmpeg/ffmpeg|twopass|-pix_fmt|yuv420p|-f|mp4|-movflags|+faststart|-profile:v|high|-preset|slow|-vcodec|libx264|-bf|0|-refs|4|-b:v|2000k|-maxrate:v|3000k|-bufsize:v|6000k|-minrate:v|2000k|-tune|animation|-x264opts|rc-lookahead=48:keyint=96|-keyint_min|48|-g|96|-force_key_frames|expr:eq(mod(n,48),0)|-hide_banner|-nostdin|-copyts|-start_at_zero|-max_delay|0|-max_muxing_queue_size|1024|-nostats;\
02000VP9|FFmpeg/ffmpeg|twopass|-pix_fmt|yuv420p|-f|mp4|-movflags|+faststart|-profile:v|high|-preset|slow|-vcodec|libvpx-vp9|-speed|2|-b:v|2000k|-maxrate:v|3000k|-bufsize:v|6000k|-minrate:v|2000k|-keyint_min|48|-g|48|-hide_banner|-nostdin|-copyts|-start_at_zero|-max_delay|0|-max_muxing_queue_size|1024|-nostats|-row-mt|1;\
02500H264|FFmpeg/ffmpeg|twopass|-pix_fmt|yuv420p|-f|mp4|-movflags|+faststart|-profile:v|high|-preset|slow|-vcodec|libx264|-bf|0|-refs|4|-b:v|2500k|-maxrate:v|3750k|-bufsize:v|7500k|-minrate:v|2500k|-tune|animation|-x264opts|rc-lookahead=48:keyint=96|-keyint_min|48|-g|96|-force_key_frames|expr:eq(mod(n,48),0)|-hide_banner|-nostdin|-copyts|-start_at_zero|-max_delay|0|-max_muxing_queue_size|1024|-nostats;\
02500VP9|FFmpeg/ffmpeg|twopass|-pix_fmt|yuv420p|-f|mp4|-movflags|+faststart|-profile:v|high|-preset|slow|-vcodec|libvpx-vp9|-speed|2|-b:v|2500k|-maxrate:v|3750k|-bufsize:v|7500k|-minrate:v|2500k|-keyint_min|48|-g|48|-hide_banner|-nostdin|-copyts|-start_at_zero|-max_delay|0|-max_muxing_queue_size|1024|-nostats|-row-mt|1;\
03000H264|FFmpeg/ffmpeg|twopass|-pix_fmt|yuv420p|-f|mp4|-movflags|+faststart|-profile:v|high|-preset|slow|-vcodec|libx264|-bf|0|-refs|4|-b:v|3000k|-maxrate:v|4500k|-bufsize:v|9000k|-minrate:v|3000k|-tune|animation|-x264opts|rc-lookahead=48:keyint=96|-keyint_min|48|-g|96|-force_key_frames|expr:eq(mod(n,48),0)|-hide_banner|-nostdin|-copyts|-start_at_zero|-max_delay|0|-max_muxing_queue_size|1024|-nostats;\
03000VP9|FFmpeg/ffmpeg|twopass|-pix_fmt|yuv420p|-f|mp4|-movflags|+faststart|-profile:v|high|-preset|slow|-vcodec|libvpx-vp9|-speed|2|-b:v|3000k|-maxrate:v|4500k|-bufsize:v|9000k|-minrate:v|3000k|-keyint_min|48|-g|48|-hide_banner|-nostdin|-copyts|-start_at_zero|-max_delay|0|-max_muxing_queue_size|1024|-nostats|-row-mt|1;\
03500H264|FFmpeg/ffmpeg|twopass|-pix_fmt|yuv420p|-f|mp4|-movflags|+faststart|-profile:v|high|-preset|slow|-vcodec|libx264|-bf|0|-refs|4|-b:v|3500k|-maxrate:v|5250k|-bufsize:v|10500k|-minrate:v|3500k|-tune|animation|-x264opts|rc-lookahead=48:keyint=96|-keyint_min|48|-g|96|-force_key_frames|expr:eq(mod(n,48),0)|-hide_banner|-nostdin|-copyts|-start_at_zero|-max_delay|0|-max_muxing_queue_size|1024|-nostats;\
03500VP9|FFmpeg/ffmpeg|twopass|-pix_fmt|yuv420p|-f|mp4|-movflags|+faststart|-profile:v|high|-preset|slow|-vcodec|libvpx-vp9|-speed|2|-b:v|3500k|-maxrate:v|5250k|-bufsize:v|10500k|-minrate:v|3500k|-keyint_min|48|-g|48|-hide_banner|-nostdin|-copyts|-start_at_zero|-max_delay|0|-max_muxing_queue_size|1024|-nostats|-row-mt|1;\
04000H264|FFmpeg/ffmpeg|twopass|-pix_fmt|yuv420p|-f|mp4|-movflags|+faststart|-profile:v|high|-preset|slow|-vcodec|libx264|-bf|0|-refs|4|-b:v|4000k|-maxrate:v|6000k|-bufsize:v|12000k|-minrate:v|4000k|-tune|animation|-x264opts|rc-lookahead=48:keyint=96|-keyint_min|48|-g|96|-force_key_frames|expr:eq(mod(n,48),0)|-hide_banner|-nostdin|-copyts|-start_at_zero|-max_delay|0|-max_muxing_queue_size|1024|-nostats;\
04000VP9|FFmpeg/ffmpeg|twopass|-pix_fmt|yuv420p|-f|mp4|-movflags|+faststart|-profile:v|high|-preset|slow|-vcodec|libvpx-vp9|-speed|2|-b:v|4000k|-maxrate:v|6000k|-bufsize:v|12000k|-minrate:v|4000k|-keyint_min|48|-g|48|-hide_banner|-nostdin|-copyts|-start_at_zero|-max_delay|0|-max_muxing_queue_size|1024|-nostats|-row-mt|1;\
04500H264|FFmpeg/ffmpeg|twopass|-pix_fmt|yuv420p|-f|mp4|-movflags|+faststart|-profile:v|high|-preset|slow|-vcodec|libx264|-bf|0|-refs|4|-b:v|4500k|-maxrate:v|6750k|-bufsize:v|13500k|-minrate:v|4500k|-tune|animation|-x264opts|rc-lookahead=48:keyint=96|-keyint_min|48|-g|96|-force_key_frames|expr:eq(mod(n,48),0)|-hide_banner|-nostdin|-copyts|-start_at_zero|-max_delay|0|-max_muxing_queue_size|1024|-nostats;\
04500VP9|FFmpeg/ffmpeg|twopass|-pix_fmt|yuv420p|-f|mp4|-movflags|+faststart|-profile:v|high|-preset|slow|-vcodec|libvpx-vp9|-speed|2|-b:v|4500k|-maxrate:v|6750k|-bufsize:v|13500k|-minrate:v|4500k|-keyint_min|48|-g|48|-hide_banner|-nostdin|-copyts|-start_at_zero|-max_delay|0|-max_muxing_queue_size|1024|-nostats|-row-mt|1;\
05000H264|FFmpeg/ffmpeg|twopass|-pix_fmt|yuv420p|-f|mp4|-movflags|+faststart|-profile:v|high|-preset|slow|-vcodec|libx264|-bf|0|-refs|4|-b:v|5000k|-maxrate:v|7500k|-bufsize:v|15000k|-minrate:v|5000k|-tune|animation|-x264opts|rc-lookahead=48:keyint=96|-keyint_min|48|-g|96|-force_key_frames|expr:eq(mod(n,48),0)|-hide_banner|-nostdin|-copyts|-start_at_zero|-max_delay|0|-max_muxing_queue_size|1024|-nostats;\
05000VP9|FFmpeg/ffmpeg|twopass|-pix_fmt|yuv420p|-f|mp4|-movflags|+faststart|-profile:v|high|-preset|slow|-vcodec|libvpx-vp9|-speed|2|-b:v|5000k|-maxrate:v|7500k|-bufsize:v|15000k|-minrate:v|5000k|-keyint_min|48|-g|48|-hide_banner|-nostdin|-copyts|-start_at_zero|-max_delay|0|-max_muxing_queue_size|1024|-nostats|-row-mt|1;\
05500H264|FFmpeg/ffmpeg|twopass|-pix_fmt|yuv420p|-f|mp4|-movflags|+faststart|-profile:v|high|-preset|slow|-vcodec|libx264|-bf|0|-refs|4|-b:v|5500k|-maxrate:v|8250k|-bufsize:v|16500k|-minrate:v|5500k|-tune|animation|-x264opts|rc-lookahead=48:keyint=96|-keyint_min|48|-g|96|-force_key_frames|expr:eq(mod(n,48),0)|-hide_banner|-nostdin|-copyts|-start_at_zero|-max_delay|0|-max_muxing_queue_size|1024|-nostats;\
05500VP9|FFmpeg/ffmpeg|twopass|-pix_fmt|yuv420p|-f|mp4|-movflags|+faststart|-profile:v|high|-preset|slow|-vcodec|libvpx-vp9|-speed|2|-b:v|5500k|-maxrate:v|8250k|-bufsize:v|16500k|-minrate:v|5500k|-keyint_min|48|-g|48|-hide_banner|-nostdin|-copyts|-start_at_zero|-max_delay|0|-max_muxing_queue_size|1024|-nostats|-row-mt|1;\
06000H264|FFmpeg/ffmpeg|twopass|-pix_fmt|yuv420p|-f|mp4|-movflags|+faststart|-profile:v|high|-preset|slow|-vcodec|libx264|-bf|0|-refs|4|-b:v|6000k|-maxrate:v|9000k|-bufsize:v|18000k|-minrate:v|6000k|-tune|animation|-x264opts|rc-lookahead=48:keyint=96|-keyint_min|48|-g|96|-force_key_frames|expr:eq(mod(n,48),0)|-hide_banner|-nostdin|-copyts|-start_at_zero|-max_delay|0|-max_muxing_queue_size|1024|-nostats;\
06000VP9|FFmpeg/ffmpeg|twopass|-pix_fmt|yuv420p|-f|mp4|-movflags|+faststart|-profile:v|high|-preset|slow|-vcodec|libvpx-vp9|-speed|2|-b:v|6000k|-maxrate:v|9000k|-bufsize:v|18000k|-minrate:v|6000k|-keyint_min|48|-g|48|-hide_banner|-nostdin|-copyts|-start_at_zero|-max_delay|0|-max_muxing_queue_size|1024|-nostats|-row-mt|1;\
06500H264|FFmpeg/ffmpeg|twopass|-pix_fmt|yuv420p|-f|mp4|-movflags|+faststart|-profile:v|high|-preset|slow|-vcodec|libx264|-bf|0|-refs|4|-b:v|6500k|-maxrate:v|9750k|-bufsize:v|19500k|-minrate:v|6500k|-tune|animation|-x264opts|rc-lookahead=48:keyint=96|-keyint_min|48|-g|96|-force_key_frames|expr:eq(mod(n,48),0)|-hide_banner|-nostdin|-copyts|-start_at_zero|-max_delay|0|-max_muxing_queue_size|1024|-nostats;\
06500VP9|FFmpeg/ffmpeg|twopass|-pix_fmt|yuv420p|-f|mp4|-movflags|+faststart|-profile:v|high|-preset|slow|-vcodec|libvpx-vp9|-speed|2|-b:v|6500k|-maxrate:v|9750k|-bufsize:v|19500k|-minrate:v|6500k|-keyint_min|48|-g|48|-hide_banner|-nostdin|-copyts|-start_at_zero|-max_delay|0|-max_muxing_queue_size|1024|-nostats|-row-mt|1;\
07000H264|FFmpeg/ffmpeg|twopass|-pix_fmt|yuv420p|-f|mp4|-movflags|+faststart|-profile:v|high|-preset|slow|-vcodec|libx264|-bf|0|-refs|4|-b:v|7000k|-maxrate:v|10500k|-bufsize:v|21000k|-minrate:v|7000k|-tune|animation|-x264opts|rc-lookahead=48:keyint=96|-keyint_min|48|-g|96|-force_key_frames|expr:eq(mod(n,48),0)|-hide_banner|-nostdin|-copyts|-start_at_zero|-max_delay|0|-max_muxing_queue_size|1024|-nostats;\
07000VP9|FFmpeg/ffmpeg|twopass|-pix_fmt|yuv420p|-f|mp4|-movflags|+faststart|-profile:v|high|-preset|slow|-vcodec|libvpx-vp9|-speed|2|-b:v|7000k|-maxrate:v|10500k|-bufsize:v|21000k|-minrate:v|7000k|-keyint_min|48|-g|48|-hide_banner|-nostdin|-copyts|-start_at_zero|-max_delay|0|-max_muxing_queue_size|1024|-nostats|-row-mt|1;\
07500H264|FFmpeg/ffmpeg|twopass|-pix_fmt|yuv420p|-f|mp4|-movflags|+faststart|-profile:v|high|-preset|slow|-vcodec|libx264|-bf|0|-refs|4|-b:v|7500k|-maxrate:v|11250k|-bufsize:v|22500k|-minrate:v|7500k|-tune|animation|-x264opts|rc-lookahead=48:keyint=96|-keyint_min|48|-g|96|-force_key_frames|expr:eq(mod(n,48),0)|-hide_banner|-nostdin|-copyts|-start_at_zero|-max_delay|0|-max_muxing_queue_size|1024|-nostats;\
07500VP9|FFmpeg/ffmpeg|twopass|-pix_fmt|yuv420p|-f|mp4|-movflags|+faststart|-profile:v|high|-preset|slow|-vcodec|libvpx-vp9|-speed|2|-b:v|7500k|-maxrate:v|11250k|-bufsize:v|22500k|-minrate:v|7500k|-keyint_min|48|-g|48|-hide_banner|-nostdin|-copyts|-start_at_zero|-max_delay|0|-max_muxing_queue_size|1024|-nostats|-row-mt|1;\
08000H264|FFmpeg/ffmpeg|twopass|-pix_fmt|yuv420p|-f|mp4|-movflags|+faststart|-profile:v|high|-preset|slow|-vcodec|libx264|-bf|0|-refs|4|-b:v|8000k|-maxrate:v|12000k|-bufsize:v|24000k|-minrate:v|8000k|-tune|animation|-x264opts|rc-lookahead=48:keyint=96|-keyint_min|48|-g|96|-force_key_frames|expr:eq(mod(n,48),0)|-hide_banner|-nostdin|-copyts|-start_at_zero|-max_delay|0|-max_muxing_queue_size|1024|-nostats;\
08000VP9|FFmpeg/ffmpeg|twopass|-pix_fmt|yuv420p|-f|mp4|-movflags|+faststart|-profile:v|high|-preset|slow|-vcodec|libvpx-vp9|-speed|2|-b:v|8000k|-maxrate:v|12000k|-bufsize:v|24000k|-minrate:v|8000k|-keyint_min|48|-g|48|-hide_banner|-nostdin|-copyts|-start_at_zero|-max_delay|0|-max_muxing_queue_size|1024|-nostats|-row-mt|1;\
08500H264|FFmpeg/ffmpeg|twopass|-pix_fmt|yuv420p|-f|mp4|-movflags|+faststart|-profile:v|high|-preset|slow|-vcodec|libx264|-bf|0|-refs|4|-b:v|8500k|-maxrate:v|12750k|-bufsize:v|25500k|-minrate:v|8500k|-tune|animation|-x264opts|rc-lookahead=48:keyint=96|-keyint_min|48|-g|96|-force_key_frames|expr:eq(mod(n,48),0)|-hide_banner|-nostdin|-copyts|-start_at_zero|-max_delay|0|-max_muxing_queue_size|1024|-nostats;\
08500VP9|FFmpeg/ffmpeg|twopass|-pix_fmt|yuv420p|-f|mp4|-movflags|+faststart|-profile:v|high|-preset|slow|-vcodec|libvpx-vp9|-speed|2|-b:v|8500k|-maxrate:v|12750k|-bufsize:v|25500k|-minrate:v|8500k|-keyint_min|48|-g|48|-hide_banner|-nostdin|-copyts|-start_at_zero|-max_delay|0|-max_muxing_queue_size|1024|-nostats|-row-mt|1;\
09000H264|FFmpeg/ffmpeg|twopass|-pix_fmt|yuv420p|-f|mp4|-movflags|+faststart|-profile:v|high|-preset|slow|-vcodec|libx264|-bf|0|-refs|4|-b:v|9000k|-maxrate:v|13500k|-bufsize:v|27000k|-minrate:v|9000k|-tune|animation|-x264opts|rc-lookahead=48:keyint=96|-keyint_min|48|-g|96|-force_key_frames|expr:eq(mod(n,48),0)|-hide_banner|-nostdin|-copyts|-start_at_zero|-max_delay|0|-max_muxing_queue_size|1024|-nostats;\
09000VP9|FFmpeg/ffmpeg|twopass|-pix_fmt|yuv420p|-f|mp4|-movflags|+faststart|-profile:v|high|-preset|slow|-vcodec|libvpx-vp9|-speed|2|-b:v|9000k|-maxrate:v|13500k|-bufsize:v|27000k|-minrate:v|9000k|-keyint_min|48|-g|48|-hide_banner|-nostdin|-copyts|-start_at_zero|-max_delay|0|-max_muxing_queue_size|1024|-nostats|-row-mt|1;\
09500H264|FFmpeg/ffmpeg|twopass|-pix_fmt|yuv420p|-f|mp4|-movflags|+faststart|-profile:v|high|-preset|slow|-vcodec|libx264|-bf|0|-refs|4|-b:v|9500k|-maxrate:v|14250k|-bufsize:v|28500k|-minrate:v|9500k|-tune|animation|-x264opts|rc-lookahead=48:keyint=96|-keyint_min|48|-g|96|-force_key_frames|expr:eq(mod(n,48),0)|-hide_banner|-nostdin|-copyts|-start_at_zero|-max_delay|0|-max_muxing_queue_size|1024|-nostats;\
09500VP9|FFmpeg/ffmpeg|twopass|-pix_fmt|yuv420p|-f|mp4|-movflags|+faststart|-profile:v|high|-preset|slow|-vcodec|libvpx-vp9|-speed|2|-b:v|9500k|-maxrate:v|14250k|-bufsize:v|28500k|-minrate:v|9500k|-keyint_min|48|-g|48|-hide_banner|-nostdin|-copyts|-start_at_zero|-max_delay|0|-max_muxing_queue_size|1024|-nostats|-row-mt|1;\
10000H264|FFmpeg/ffmpeg|twopass|-pix_fmt|yuv420p|-f|mp4|-movflags|+faststart|-profile:v|high|-preset|slow|-vcodec|libx264|-bf|0|-refs|4|-b:v|10000k|-maxrate:v|15000k|-bufsize:v|30000k|-minrate:v|10000k|-tune|animation|-x264opts|rc-lookahead=48:keyint=96|-keyint_min|48|-g|96|-force_key_frames|expr:eq(mod(n,48),0)|-hide_banner|-nostdin|-copyts|-start_at_zero|-max_delay|0|-max_muxing_queue_size|1024|-nostats;\
10000VP9|FFmpeg/ffmpeg|twopass|-pix_fmt|yuv420p|-f|mp4|-movflags|+faststart|-profile:v|high|-preset|slow|-vcodec|libvpx-vp9|-speed|2|-b:v|10000k|-maxrate:v|15000k|-bufsize:v|30000k|-minrate:v|10000k|-keyint_min|48|-g|48|-hide_banner|-nostdin|-copyts|-start_at_zero|-max_delay|0|-max_muxing_queue_size|1024|-nostats|-row-mt|1;\
10500H264|FFmpeg/ffmpeg|twopass|-pix_fmt|yuv420p|-f|mp4|-movflags|+faststart|-profile:v|high|-preset|slow|-vcodec|libx264|-bf|0|-refs|4|-b:v|10500k|-maxrate:v|15750k|-bufsize:v|31500k|-minrate:v|10500k|-tune|animation|-x264opts|rc-lookahead=48:keyint=96|-keyint_min|48|-g|96|-force_key_frames|expr:eq(mod(n,48),0)|-hide_banner|-nostdin|-copyts|-start_at_zero|-max_delay|0|-max_muxing_queue_size|1024|-nostats;\
10500VP9|FFmpeg/ffmpeg|twopass|-pix_fmt|yuv420p|-f|mp4|-movflags|+faststart|-profile:v|high|-preset|slow|-vcodec|libvpx-vp9|-speed|2|-b:v|10500k|-maxrate:v|15750k|-bufsize:v|31500k|-minrate:v|10500k|-keyint_min|48|-g|48|-hide_banner|-nostdin|-copyts|-start_at_zero|-max_delay|0|-max_muxing_queue_size|1024|-nostats|-row-mt|1;\
11000H264|FFmpeg/ffmpeg|twopass|-pix_fmt|yuv420p|-f|mp4|-movflags|+faststart|-profile:v|high|-preset|slow|-vcodec|libx264|-bf|0|-refs|4|-b:v|11000k|-maxrate:v|16500k|-bufsize:v|33000k|-minrate:v|11000k|-tune|animation|-x264opts|rc-lookahead=48:keyint=96|-keyint_min|48|-g|96|-force_key_frames|expr:eq(mod(n,48),0)|-hide_banner|-nostdin|-copyts|-start_at_zero|-max_delay|0|-max_muxing_queue_size|1024|-nostats;\
11000VP9|FFmpeg/ffmpeg|twopass|-pix_fmt|yuv420p|-f|mp4|-movflags|+faststart|-profile:v|high|-preset|slow|-vcodec|libvpx-vp9|-speed|2|-b:v|11000k|-maxrate:v|16500k|-bufsize:v|33000k|-minrate:v|11000k|-keyint_min|48|-g|48|-hide_banner|-nostdin|-copyts|-start_at_zero|-max_delay|0|-max_muxing_queue_size|1024|-nostats|-row-mt|1;\
11500H264|FFmpeg/ffmpeg|twopass|-pix_fmt|yuv420p|-f|mp4|-movflags|+faststart|-profile:v|high|-preset|slow|-vcodec|libx264|-bf|0|-refs|4|-b:v|11500k|-maxrate:v|17250k|-bufsize:v|34500k|-minrate:v|11500k|-tune|animation|-x264opts|rc-lookahead=48:keyint=96|-keyint_min|48|-g|96|-force_key_frames|expr:eq(mod(n,48),0)|-hide_banner|-nostdin|-copyts|-start_at_zero|-max_delay|0|-max_muxing_queue_size|1024|-nostats;\
11500VP9|FFmpeg/ffmpeg|twopass|-pix_fmt|yuv420p|-f|mp4|-movflags|+faststart|-profile:v|high|-preset|slow|-vcodec|libvpx-vp9|-speed|2|-b:v|11500k|-maxrate:v|17250k|-bufsize:v|34500k|-minrate:v|11500k|-keyint_min|48|-g|48|-hide_banner|-nostdin|-copyts|-start_at_zero|-max_delay|0|-max_muxing_queue_size|1024|-nostats|-row-mt|1;\
12000H264|FFmpeg/ffmpeg|twopass|-pix_fmt|yuv420p|-f|mp4|-movflags|+faststart|-profile:v|high|-preset|slow|-vcodec|libx264|-bf|0|-refs|4|-b:v|12000k|-maxrate:v|18000k|-bufsize:v|36000k|-minrate:v|12000k|-tune|animation|-x264opts|rc-lookahead=48:keyint=96|-keyint_min|48|-g|96|-force_key_frames|expr:eq(mod(n,48),0)|-hide_banner|-nostdin|-copyts|-start_at_zero|-max_delay|0|-max_muxing_queue_size|1024|-nostats;\
12000VP9|FFmpeg/ffmpeg|twopass|-pix_fmt|yuv420p|-f|mp4|-movflags|+faststart|-profile:v|high|-preset|slow|-vcodec|libvpx-vp9|-speed|2|-b:v|12000k|-maxrate:v|18000k|-bufsize:v|36000k|-minrate:v|12000k|-keyint_min|48|-g|48|-hide_banner|-nostdin|-copyts|-start_at_zero|-max_delay|0|-max_muxing_queue_size|1024|-nostats|-row-mt|1;\
12500H264|FFmpeg/ffmpeg|twopass|-pix_fmt|yuv420p|-f|mp4|-movflags|+faststart|-profile:v|high|-preset|slow|-vcodec|libx264|-bf|0|-refs|4|-b:v|12500k|-maxrate:v|18750k|-bufsize:v|37500k|-minrate:v|12500k|-tune|animation|-x264opts|rc-lookahead=48:keyint=96|-keyint_min|48|-g|96|-force_key_frames|expr:eq(mod(n,48),0)|-hide_banner|-nostdin|-copyts|-start_at_zero|-max_delay|0|-max_muxing_queue_size|1024|-nostats;\
12500VP9|FFmpeg/ffmpeg|twopass|-pix_fmt|yuv420p|-f|mp4|-movflags|+faststart|-profile:v|high|-preset|slow|-vcodec|libvpx-vp9|-speed|2|-b:v|12500k|-maxrate:v|18750k|-bufsize:v|37500k|-minrate:v|12500k|-keyint_min|48|-g|48|-hide_banner|-nostdin|-copyts|-start_at_zero|-max_delay|0|-max_muxing_queue_size|1024|-nostats|-row-mt|1;\
13000H264|FFmpeg/ffmpeg|twopass|-pix_fmt|yuv420p|-f|mp4|-movflags|+faststart|-profile:v|high|-preset|slow|-vcodec|libx264|-bf|0|-refs|4|-b:v|13000k|-maxrate:v|19500k|-bufsize:v|39000k|-minrate:v|13000k|-tune|animation|-x264opts|rc-lookahead=48:keyint=96|-keyint_min|48|-g|96|-force_key_frames|expr:eq(mod(n,48),0)|-hide_banner|-nostdin|-copyts|-start_at_zero|-max_delay|0|-max_muxing_queue_size|1024|-nostats;\
13000VP9|FFmpeg/ffmpeg|twopass|-pix_fmt|yuv420p|-f|mp4|-movflags|+faststart|-profile:v|high|-preset|slow|-vcodec|libvpx-vp9|-speed|2|-b:v|13000k|-maxrate:v|19500k|-bufsize:v|39000k|-minrate:v|13000k|-keyint_min|48|-g|48|-hide_banner|-nostdin|-copyts|-start_at_zero|-max_delay|0|-max_muxing_queue_size|1024|-nostats|-row-mt|1;\
13500H264|FFmpeg/ffmpeg|twopass|-pix_fmt|yuv420p|-f|mp4|-movflags|+faststart|-profile:v|high|-preset|slow|-vcodec|libx264|-bf|0|-refs|4|-b:v|13500k|-maxrate:v|20250k|-bufsize:v|40500k|-minrate:v|13500k|-tune|animation|-x264opts|rc-lookahead=48:keyint=96|-keyint_min|48|-g|96|-force_key_frames|expr:eq(mod(n,48),0)|-hide_banner|-nostdin|-copyts|-start_at_zero|-max_delay|0|-max_muxing_queue_size|1024|-nostats;\
13500VP9|FFmpeg/ffmpeg|twopass|-pix_fmt|yuv420p|-f|mp4|-movflags|+faststart|-profile:v|high|-preset|slow|-vcodec|libvpx-vp9|-speed|2|-b:v|13500k|-maxrate:v|20250k|-bufsize:v|40500k|-minrate:v|13500k|-keyint_min|48|-g|48|-hide_banner|-nostdin|-copyts|-start_at_zero|-max_delay|0|-max_muxing_queue_size|1024|-nostats|-row-mt|1;\
14000H264|FFmpeg/ffmpeg|twopass|-pix_fmt|yuv420p|-f|mp4|-movflags|+faststart|-profile:v|high|-preset|slow|-vcodec|libx264|-bf|0|-refs|4|-b:v|14000k|-maxrate:v|21000k|-bufsize:v|42000k|-minrate:v|14000k|-tune|animation|-x264opts|rc-lookahead=48:keyint=96|-keyint_min|48|-g|96|-force_key_frames|expr:eq(mod(n,48),0)|-hide_banner|-nostdin|-copyts|-start_at_zero|-max_delay|0|-max_muxing_queue_size|1024|-nostats;\
14000VP9|FFmpeg/ffmpeg|twopass|-pix_fmt|yuv420p|-f|mp4|-movflags|+faststart|-profile:v|high|-preset|slow|-vcodec|libvpx-vp9|-speed|2|-b:v|14000k|-maxrate:v|21000k|-bufsize:v|42000k|-minrate:v|14000k|-keyint_min|48|-g|48|-hide_banner|-nostdin|-copyts|-start_at_zero|-max_delay|0|-max_muxing_queue_size|1024|-nostats|-row-mt|1;\
14500H264|FFmpeg/ffmpeg|twopass|-pix_fmt|yuv420p|-f|mp4|-movflags|+faststart|-profile:v|high|-preset|slow|-vcodec|libx264|-bf|0|-refs|4|-b:v|14500k|-maxrate:v|21750k|-bufsize:v|43500k|-minrate:v|14500k|-tune|animation|-x264opts|rc-lookahead=48:keyint=96|-keyint_min|48|-g|96|-force_key_frames|expr:eq(mod(n,48),0)|-hide_banner|-nostdin|-copyts|-start_at_zero|-max_delay|0|-max_muxing_queue_size|1024|-nostats;\
14500VP9|FFmpeg/ffmpeg|twopass|-pix_fmt|yuv420p|-f|mp4|-movflags|+faststart|-profile:v|high|-preset|slow|-vcodec|libvpx-vp9|-speed|2|-b:v|14500k|-maxrate:v|21750k|-bufsize:v|43500k|-minrate:v|14500k|-keyint_min|48|-g|48|-hide_banner|-nostdin|-copyts|-start_at_zero|-max_delay|0|-max_muxing_queue_size|1024|-nostats|-row-mt|1;\
15000H264|FFmpeg/ffmpeg|twopass|-pix_fmt|yuv420p|-f|mp4|-movflags|+faststart|-profile:v|high|-preset|slow|-vcodec|libx264|-bf|0|-refs|4|-b:v|15000k|-maxrate:v|22500k|-bufsize:v|45000k|-minrate:v|15000k|-tune|animation|-x264opts|rc-lookahead=48:keyint=96|-keyint_min|48|-g|96|-force_key_frames|expr:eq(mod(n,48),0)|-hide_banner|-nostdin|-copyts|-start_at_zero|-max_delay|0|-max_muxing_queue_size|1024|-nostats;\
15000VP9|FFmpeg/ffmpeg|twopass|-pix_fmt|yuv420p|-f|mp4|-movflags|+faststart|-profile:v|high|-preset|slow|-vcodec|libvpx-vp9|-speed|2|-b:v|15000k|-maxrate:v|22500k|-bufsize:v|45000k|-minrate:v|15000k|-keyint_min|48|-g|48|-hide_banner|-nostdin|-copyts|-start_at_zero|-max_delay|0|-max_muxing_queue_size|1024|-nostats|-row-mt|1;\
15500H264|FFmpeg/ffmpeg|twopass|-pix_fmt|yuv420p|-f|mp4|-movflags|+faststart|-profile:v|high|-preset|slow|-vcodec|libx264|-bf|0|-refs|4|-b:v|15500k|-maxrate:v|23250k|-bufsize:v|46500k|-minrate:v|15500k|-tune|animation|-x264opts|rc-lookahead=48:keyint=96|-keyint_min|48|-g|96|-force_key_frames|expr:eq(mod(n,48),0)|-hide_banner|-nostdin|-copyts|-start_at_zero|-max_delay|0|-max_muxing_queue_size|1024|-nostats;\
15500VP9|FFmpeg/ffmpeg|twopass|-pix_fmt|yuv420p|-f|mp4|-movflags|+faststart|-profile:v|high|-preset|slow|-vcodec|libvpx-vp9|-speed|2|-b:v|15500k|-maxrate:v|23250k|-bufsize:v|46500k|-minrate:v|15500k|-keyint_min|48|-g|48|-hide_banner|-nostdin|-copyts|-start_at_zero|-max_delay|0|-max_muxing_queue_size|1024|-nostats|-row-mt|1;\
16000H264|FFmpeg/ffmpeg|twopass|-pix_fmt|yuv420p|-f|mp4|-movflags|+faststart|-profile:v|high|-preset|slow|-vcodec|libx264|-bf|0|-refs|4|-b:v|16000k|-maxrate:v|24000k|-bufsize:v|48000k|-minrate:v|16000k|-tune|animation|-x264opts|rc-lookahead=48:keyint=96|-keyint_min|48|-g|96|-force_key_frames|expr:eq(mod(n,48),0)|-hide_banner|-nostdin|-copyts|-start_at_zero|-max_delay|0|-max_muxing_queue_size|1024|-nostats;\
16000VP9|FFmpeg/ffmpeg|twopass|-pix_fmt|yuv420p|-f|mp4|-movflags|+faststart|-profile:v|high|-preset|slow|-vcodec|libvpx-vp9|-speed|2|-b:v|16000k|-maxrate:v|24000k|-bufsize:v|48000k|-minrate:v|16000k|-keyint_min|48|-g|48|-hide_banner|-nostdin|-copyts|-start_at_zero|-max_delay|0|-max_muxing_queue_size|1024|-nostats|-row-mt|1\
"
