#!/bin/sh

bin/encode.py \
        -m vmaf,psnr \
        -n tests/test000 \
        -p 12 -t "\
01000X264H264|FFmpeg/ffmpeg|twopass|S|-pix_fmt|yuv420p|-movflags|+faststart|-profile:v|high|-preset|slow|-vcodec|libx264|-bf|0|-refs|4|-b:v|1000k|-maxrate:v|1500k|-bufsize:v|3000k|-minrate:v|1000k|-tune|animation|-x264opts|rc-lookahead=48:keyint=96|-keyint_min|48|-g|96|-force_key_frames|expr:eq(mod(n,48),0)|-hide_banner|-nostdin|-copyts|-start_at_zero|-max_delay|0|-max_muxing_queue_size|1024|-nostats;\
01000AOMAV1|FFmpeg/ffmpeg|twopass|S|-pix_fmt|yuv420p|-movflags|+faststart|-vcodec|libaom-av1|-tile-columns|3|-tile-rows|3|-strict|experimental|-b:v|1000k|-maxrate:v|1500k|-bufsize:v|3000k|-minrate:v|1000k|-keyint_min|48|-g|48|-hide_banner|-nostdin|-copyts|-start_at_zero|-max_delay|0|-max_muxing_queue_size|1024|-nostats|-row-mt|1;\
01000VPXVP9|FFmpeg/ffmpeg|twopass|S|-pix_fmt|yuv420p|-movflags|+faststart|-vcodec|libvpx-vp9|-speed|2|-b:v|1000k|-maxrate:v|1500k|-bufsize:v|3000k|-minrate:v|1000k|-keyint_min|48|-g|48|-hide_banner|-nostdin|-copyts|-start_at_zero|-max_delay|0|-max_muxing_queue_size|1024|-nostats|-row-mt|1;\
02000X264H264|FFmpeg/ffmpeg|twopass|S|-pix_fmt|yuv420p|-movflags|+faststart|-profile:v|high|-preset|slow|-vcodec|libx264|-bf|0|-refs|4|-b:v|2000k|-maxrate:v|3000k|-bufsize:v|6000k|-minrate:v|2000k|-tune|animation|-x264opts|rc-lookahead=48:keyint=96|-keyint_min|48|-g|96|-force_key_frames|expr:eq(mod(n,48),0)|-hide_banner|-nostdin|-copyts|-start_at_zero|-max_delay|0|-max_muxing_queue_size|1024|-nostats;\
02000AOMAV1|FFmpeg/ffmpeg|twopass|S|-pix_fmt|yuv420p|-movflags|+faststart|-vcodec|libaom-av1|-tile-columns|3|-tile-rows|3|-strict|experimental|-b:v|2000k|-maxrate:v|3000k|-bufsize:v|6000k|-minrate:v|2000k|-keyint_min|48|-g|48|-hide_banner|-nostdin|-copyts|-start_at_zero|-max_delay|0|-max_muxing_queue_size|1024|-nostats|-row-mt|1;\
02000VPXVP9|FFmpeg/ffmpeg|twopass|S|-pix_fmt|yuv420p|-movflags|+faststart|-vcodec|libvpx-vp9|-speed|2|-b:v|2000k|-maxrate:v|3000k|-bufsize:v|6000k|-minrate:v|2000k|-keyint_min|48|-g|48|-hide_banner|-nostdin|-copyts|-start_at_zero|-max_delay|0|-max_muxing_queue_size|1024|-nostats|-row-mt|1;\
03000X264H264|FFmpeg/ffmpeg|twopass|S|-pix_fmt|yuv420p|-movflags|+faststart|-profile:v|high|-preset|slow|-vcodec|libx264|-bf|0|-refs|4|-b:v|3000k|-maxrate:v|4500k|-bufsize:v|9000k|-minrate:v|3000k|-tune|animation|-x264opts|rc-lookahead=48:keyint=96|-keyint_min|48|-g|96|-force_key_frames|expr:eq(mod(n,48),0)|-hide_banner|-nostdin|-copyts|-start_at_zero|-max_delay|0|-max_muxing_queue_size|1024|-nostats;\
03000AOMAV1|FFmpeg/ffmpeg|twopass|S|-pix_fmt|yuv420p|-movflags|+faststart|-vcodec|libaom-av1|-tile-columns|3|-tile-rows|3|-strict|experimental|-b:v|3000k|-maxrate:v|4500k|-bufsize:v|9000k|-minrate:v|3000k|-keyint_min|48|-g|48|-hide_banner|-nostdin|-copyts|-start_at_zero|-max_delay|0|-max_muxing_queue_size|1024|-nostats|-row-mt|1;\
03000VPXVP9|FFmpeg/ffmpeg|twopass|S|-pix_fmt|yuv420p|-movflags|+faststart|-vcodec|libvpx-vp9|-speed|2|-b:v|3000k|-maxrate:v|4500k|-bufsize:v|9000k|-minrate:v|3000k|-keyint_min|48|-g|48|-hide_banner|-nostdin|-copyts|-start_at_zero|-max_delay|0|-max_muxing_queue_size|1024|-nostats|-row-mt|1;\
04000X264H264|FFmpeg/ffmpeg|twopass|S|-pix_fmt|yuv420p|-movflags|+faststart|-profile:v|high|-preset|slow|-vcodec|libx264|-bf|0|-refs|4|-b:v|4000k|-maxrate:v|6000k|-bufsize:v|12000k|-minrate:v|4000k|-tune|animation|-x264opts|rc-lookahead=48:keyint=96|-keyint_min|48|-g|96|-force_key_frames|expr:eq(mod(n,48),0)|-hide_banner|-nostdin|-copyts|-start_at_zero|-max_delay|0|-max_muxing_queue_size|1024|-nostats;\
04000AOMAV1|FFmpeg/ffmpeg|twopass|S|-pix_fmt|yuv420p|-movflags|+faststart|-vcodec|libaom-av1|-strict|experimental|-b:v|4000k|-maxrate:v|6000k|-bufsize:v|12000k|-minrate:v|4000k|-keyint_min|48|-g|48|-hide_banner|-nostdin|-copyts|-start_at_zero|-max_delay|0|-max_muxing_queue_size|1024|-nostats|-row-mt|1;\
04000VPXVP9|FFmpeg/ffmpeg|twopass|S|-pix_fmt|yuv420p|-movflags|+faststart|-vcodec|libvpx-vp9|-speed|2|-b:v|4000k|-maxrate:v|6000k|-bufsize:v|12000k|-minrate:v|4000k|-keyint_min|48|-g|48|-hide_banner|-nostdin|-copyts|-start_at_zero|-max_delay|0|-max_muxing_queue_size|1024|-nostats|-row-mt|1;\
05000X264H264|FFmpeg/ffmpeg|twopass|S|-pix_fmt|yuv420p|-movflags|+faststart|-profile:v|high|-preset|slow|-vcodec|libx264|-bf|0|-refs|4|-b:v|5000k|-maxrate:v|7500k|-bufsize:v|15000k|-minrate:v|5000k|-tune|animation|-x264opts|rc-lookahead=48:keyint=96|-keyint_min|48|-g|96|-force_key_frames|expr:eq(mod(n,48),0)|-hide_banner|-nostdin|-copyts|-start_at_zero|-max_delay|0|-max_muxing_queue_size|1024|-nostats;\
05000AOMAV1|FFmpeg/ffmpeg|twopass|S|-pix_fmt|yuv420p|-movflags|+faststart|-vcodec|libaom-av1|-strict|experimental|-b:v|5000k|-maxrate:v|7500k|-bufsize:v|15000k|-minrate:v|5000k|-keyint_min|48|-g|48|-hide_banner|-nostdin|-copyts|-start_at_zero|-max_delay|0|-max_muxing_queue_size|1024|-nostats|-row-mt|1;\
05000VPXVP9|FFmpeg/ffmpeg|twopass|S|-pix_fmt|yuv420p|-movflags|+faststart|-vcodec|libvpx-vp9|-speed|2|-b:v|5000k|-maxrate:v|7500k|-bufsize:v|15000k|-minrate:v|5000k|-keyint_min|48|-g|48|-hide_banner|-nostdin|-copyts|-start_at_zero|-max_delay|0|-max_muxing_queue_size|1024|-nostats|-row-mt|1;\
06000X264H264|FFmpeg/ffmpeg|twopass|S|-pix_fmt|yuv420p|-movflags|+faststart|-profile:v|high|-preset|slow|-vcodec|libx264|-bf|0|-refs|4|-b:v|6000k|-maxrate:v|9000k|-bufsize:v|18000k|-minrate:v|6000k|-tune|animation|-x264opts|rc-lookahead=48:keyint=96|-keyint_min|48|-g|96|-force_key_frames|expr:eq(mod(n,48),0)|-hide_banner|-nostdin|-copyts|-start_at_zero|-max_delay|0|-max_muxing_queue_size|1024|-nostats;\
06000AOMAV1|FFmpeg/ffmpeg|twopass|S|-pix_fmt|yuv420p|-movflags|+faststart|-vcodec|libaom-av1|-strict|experimental|-b:v|6000k|-maxrate:v|9000k|-bufsize:v|18000k|-minrate:v|6000k|-keyint_min|48|-g|48|-hide_banner|-nostdin|-copyts|-start_at_zero|-max_delay|0|-max_muxing_queue_size|1024|-nostats|-row-mt|1;\
06000VPXVP9|FFmpeg/ffmpeg|twopass|S|-pix_fmt|yuv420p|-movflags|+faststart|-vcodec|libvpx-vp9|-speed|2|-b:v|6000k|-maxrate:v|9000k|-bufsize:v|18000k|-minrate:v|6000k|-keyint_min|48|-g|48|-hide_banner|-nostdin|-copyts|-start_at_zero|-max_delay|0|-max_muxing_queue_size|1024|-nostats|-row-mt|1;\
07000X264H264|FFmpeg/ffmpeg|twopass|S|-pix_fmt|yuv420p|-movflags|+faststart|-profile:v|high|-preset|slow|-vcodec|libx264|-bf|0|-refs|4|-b:v|7000k|-maxrate:v|10500k|-bufsize:v|21000k|-minrate:v|7000k|-tune|animation|-x264opts|rc-lookahead=48:keyint=96|-keyint_min|48|-g|96|-force_key_frames|expr:eq(mod(n,48),0)|-hide_banner|-nostdin|-copyts|-start_at_zero|-max_delay|0|-max_muxing_queue_size|1024|-nostats;\
07000AOMAV1|FFmpeg/ffmpeg|twopass|S|-pix_fmt|yuv420p|-movflags|+faststart|-vcodec|libaom-av1|-strict|experimental|-b:v|7000k|-maxrate:v|10500k|-bufsize:v|21000k|-minrate:v|7000k|-keyint_min|48|-g|48|-hide_banner|-nostdin|-copyts|-start_at_zero|-max_delay|0|-max_muxing_queue_size|1024|-nostats|-row-mt|1;\
07000VPXVP9|FFmpeg/ffmpeg|twopass|S|-pix_fmt|yuv420p|-movflags|+faststart|-vcodec|libvpx-vp9|-speed|2|-b:v|7000k|-maxrate:v|10500k|-bufsize:v|21000k|-minrate:v|7000k|-keyint_min|48|-g|48|-hide_banner|-nostdin|-copyts|-start_at_zero|-max_delay|0|-max_muxing_queue_size|1024|-nostats|-row-mt|1;\
08000X264H264|FFmpeg/ffmpeg|twopass|S|-pix_fmt|yuv420p|-movflags|+faststart|-profile:v|high|-preset|slow|-vcodec|libx264|-bf|0|-refs|4|-b:v|8000k|-maxrate:v|12000k|-bufsize:v|24000k|-minrate:v|8000k|-tune|animation|-x264opts|rc-lookahead=48:keyint=96|-keyint_min|48|-g|96|-force_key_frames|expr:eq(mod(n,48),0)|-hide_banner|-nostdin|-copyts|-start_at_zero|-max_delay|0|-max_muxing_queue_size|1024|-nostats;\
08000AOMAV1|FFmpeg/ffmpeg|twopass|S|-pix_fmt|yuv420p|-movflags|+faststart|-vcodec|libaom-av1|-strict|experimental|-b:v|8000k|-maxrate:v|12000k|-bufsize:v|24000k|-minrate:v|8000k|-keyint_min|48|-g|48|-hide_banner|-nostdin|-copyts|-start_at_zero|-max_delay|0|-max_muxing_queue_size|1024|-nostats|-row-mt|1;\
08000VPXVP9|FFmpeg/ffmpeg|twopass|S|-pix_fmt|yuv420p|-movflags|+faststart|-vcodec|libvpx-vp9|-speed|2|-b:v|8000k|-maxrate:v|12000k|-bufsize:v|24000k|-minrate:v|8000k|-keyint_min|48|-g|48|-hide_banner|-nostdin|-copyts|-start_at_zero|-max_delay|0|-max_muxing_queue_size|1024|-nostats|-row-mt|1;\
"
