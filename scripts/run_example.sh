#!/bin/sh

bin/encode.py \
        -m vmaf,psnr,phqm,ssim \
        -n tests/test000 \
        -p 16 -t "\
03000X264H264|ffmpeg|twopass|S|mp4|-pix_fmt|yuv420p|-f|mp4|-movflags|+faststart|-profile:v|high|-preset|slow|-vcodec|libx264|-bf|0|-refs|4|-b:v|3000k|-maxrate:v|4500k|-bufsize:v|9000k|-minrate:v|3000k|-tune|animation|-x264opts|rc-lookahead=48:keyint=96|-keyint_min|48|-g|96|-force_key_frames|expr:eq(mod(n,48),0)|-hide_banner|-nostats;\
03000AOMAV1|ffmpeg|twopass|S|mp4|-pix_fmt|yuv420p|-f|mp4|-movflags|+faststart|-vcodec|libaom-av1|-cpu-used|1|-strict|experimental|-b:v|3000k|-maxrate:v|4500k|-bufsize:v|9000k|-minrate:v|3000k|-keyint_min|48|-g|48|-hide_banner|-nostats|-row-mt|1;\
03000RAV1EAV1|ffmpeg|twopass|S|mp4|-pix_fmt|yuv420p|-f|mp4|-movflags|+faststart|-vcodec|librav1e|-speed|3|-b:v|3000k|-keyint_min|48|-g|48|-hide_banner|-nostats;\
03000SVTAV1|SvtAv1EncApp|vbr||mp4|-enc-mode|3|-film-grain|0|-adaptive-quantization|0|-rc|1|-tbr|3000|-intra-period|48|-irefresh-type|1;\
03000VPXVP9|ffmpeg|twopass|S|mp4|-pix_fmt|yuv420p|-f|mp4|-movflags|+faststart|-vcodec|libvpx-vp9|-speed|0|-b:v|3000k|-maxrate:v|4500k|-bufsize:v|9000k|-minrate:v|3000k|-g|48|-hide_banner|-nostats|-row-mt|1|-tune-content|0|-tile-columns|1|-aq-mode|0|-overshoot-pct|0|-undershoot-pct|0|-auto-alt-ref|1;\
04000X264H264|ffmpeg|twopass|S|mp4|-pix_fmt|yuv420p|-f|mp4|-movflags|+faststart|-profile:v|high|-preset|slow|-vcodec|libx264|-bf|0|-refs|4|-b:v|4000k|-maxrate:v|6000k|-bufsize:v|12000k|-minrate:v|4000k|-tune|animation|-x264opts|rc-lookahead=48:keyint=96|-keyint_min|48|-g|96|-force_key_frames|expr:eq(mod(n,48),0)|-hide_banner|-nostats;\
04000AOMAV1|ffmpeg|twopass|S|mp4|-pix_fmt|yuv420p|-f|mp4|-movflags|+faststart|-vcodec|libaom-av1|-cpu-used|1|-strict|experimental|-b:v|4000k|-maxrate:v|6000k|-bufsize:v|12000k|-minrate:v|4000k|-keyint_min|48|-g|48|-hide_banner|-nostats|-row-mt|1;\
04000RAV1EAV1|ffmpeg|twopass|S|mp4|-pix_fmt|yuv420p|-f|mp4|-movflags|+faststart|-vcodec|librav1e|-speed|3|-b:v|4000k|-keyint_min|48|-g|48|-hide_banner|-nostats;\
04000SVTAV1|SvtAv1EncApp|vbr||mp4|-enc-mode|3|-film-grain|0|-adaptive-quantization|0|-rc|1|-tbr|4000|-intra-period|48|-irefresh-type|1;\
04000VPXVP9|ffmpeg|twopass|S|mp4|-pix_fmt|yuv420p|-f|mp4|-movflags|+faststart|-vcodec|libvpx-vp9|-speed|0|-b:v|4000k|-maxrate:v|6000k|-bufsize:v|12000k|-minrate:v|4000k|-g|48|-hide_banner|-nostats|-row-mt|1|-tune-content|0|-tile-columns|1|-aq-mode|0|-overshoot-pct|0|-undershoot-pct|0|-auto-alt-ref|1;\
05000X264H264|ffmpeg|twopass|S|mp4|-pix_fmt|yuv420p|-f|mp4|-movflags|+faststart|-profile:v|high|-preset|slow|-vcodec|libx264|-bf|0|-refs|4|-b:v|5000k|-maxrate:v|7500k|-bufsize:v|15000k|-minrate:v|5000k|-tune|animation|-x264opts|rc-lookahead=48:keyint=96|-keyint_min|48|-g|96|-force_key_frames|expr:eq(mod(n,48),0)|-hide_banner|-nostats;\
05000AOMAV1|ffmpeg|twopass|S|mp4|-pix_fmt|yuv420p|-f|mp4|-movflags|+faststart|-vcodec|libaom-av1|-cpu-used|1|-strict|experimental|-b:v|5000k|-maxrate:v|7500k|-bufsize:v|15000k|-minrate:v|5000k|-keyint_min|48|-g|48|-hide_banner|-nostats|-row-mt|1;\
05000RAV1EAV1|ffmpeg|twopass|S|mp4|-pix_fmt|yuv420p|-f|mp4|-movflags|+faststart|-vcodec|librav1e|-speed|3|-b:v|5000k|-keyint_min|48|-g|48|-hide_banner|-nostats;\
05000SVTAV1|SvtAv1EncApp|vbr||mp4|-enc-mode|3|-film-grain|0|-adaptive-quantization|0|-rc|1|-tbr|5000|-intra-period|48|-irefresh-type|1;\
05000VPXVP9|ffmpeg|twopass|S|mp4|-pix_fmt|yuv420p|-f|mp4|-movflags|+faststart|-vcodec|libvpx-vp9|-speed|0|-b:v|5000k|-maxrate:v|7500k|-bufsize:v|15000k|-minrate:v|5000k|-g|48|-hide_banner|-nostats|-row-mt|1|-tune-content|0|-tile-columns|1|-aq-mode|0|-overshoot-pct|0|-undershoot-pct|0|-auto-alt-ref|1;\
06000X264H264|ffmpeg|twopass|S|mp4|-pix_fmt|yuv420p|-f|mp4|-movflags|+faststart|-profile:v|high|-preset|slow|-vcodec|libx264|-bf|0|-refs|4|-b:v|6000k|-maxrate:v|9000k|-bufsize:v|18000k|-minrate:v|6000k|-tune|animation|-x264opts|rc-lookahead=48:keyint=96|-keyint_min|48|-g|96|-force_key_frames|expr:eq(mod(n,48),0)|-hide_banner|-nostats;\
06000AOMAV1|ffmpeg|twopass|S|mp4|-pix_fmt|yuv420p|-f|mp4|-movflags|+faststart|-vcodec|libaom-av1|-cpu-used|1|-strict|experimental|-b:v|6000k|-maxrate:v|9000k|-bufsize:v|18000k|-minrate:v|6000k|-keyint_min|48|-g|48|-hide_banner|-nostats|-row-mt|1;\
06000RAV1EAV1|ffmpeg|twopass|S|mp4|-pix_fmt|yuv420p|-f|mp4|-movflags|+faststart|-vcodec|librav1e|-speed|3|-b:v|6000k|-keyint_min|48|-g|48|-hide_banner|-nostats;\
06000SVTAV1|SvtAv1EncApp|vbr||mp4|-enc-mode|3|-film-grain|0|-adaptive-quantization|0|-rc|1|-tbr|6000|-intra-period|48|-irefresh-type|1;\
06000VPXVP9|ffmpeg|twopass|S|mp4|-pix_fmt|yuv420p|-f|mp4|-movflags|+faststart|-vcodec|libvpx-vp9|-speed|0|-b:v|6000k|-maxrate:v|9000k|-bufsize:v|18000k|-minrate:v|6000k|-g|48|-hide_banner|-nostats|-row-mt|1|-tune-content|0|-tile-columns|1|-aq-mode|0|-overshoot-pct|0|-undershoot-pct|0|-auto-alt-ref|1;\
"
