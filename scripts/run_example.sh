#!/bin/sh

bin/encode.py \
        -m vmaf,psnr,phqm,ssim \
        -n tests/test000 \
        -p 16 -t "\
01000X264H264|ffmpeg|twopass|S|mp4|-pix_fmt|yuv420p|-f|mp4|-movflags|+faststart|-profile:v|high|-preset|slow|-vcodec|libx264|-bf|0|-refs|4|-b:v|1000k|-maxrate:v|1500k|-bufsize:v|3000k|-minrate:v|1000k|-tune|animation|-x264opts|rc-lookahead=48:keyint=96|-keyint_min|48|-g|96|-force_key_frames|expr:eq(mod(n,48),0)|-hide_banner|-nostats;\
01000AOMAV1|ffmpeg|twopass|S|mp4|-pix_fmt|yuv420p|-f|mp4|-movflags|+faststart|-vcodec|libaom-av1|-cpu-used|2|-strict|experimental|-b:v|1000k|-maxrate:v|1500k|-bufsize:v|3000k|-minrate:v|1000k|-keyint_min|48|-g|48|-hide_banner|-nostats|-row-mt|1;\
01000RAV1EAV1|ffmpeg|twopass|S|mp4|-pix_fmt|yuv420p|-f|mp4|-movflags|+faststart|-vcodec|librav1e|-speed|6|-b:v|1000k|-keyint_min|48|-g|48|-hide_banner|-nostats;\
01000SVTAV1|SvtAv1EncApp|twopass||mp4|-enc-mode|3|-film-grain|0|-adaptive-quantization|0|-rc|2|-tbr|1000000|-intra-period|23|-irefresh-type|1;\
01000SVTVP9|SvtVp9EncApp|vbr||mp4|-enc-mode|0|-tune|2|-rc|1|-tbr|1000000|-vbv-maxrate|1500000|-vbv-bufsize|3000000|-intra-period|48|-irefresh-type|2;\
01000VPXVP9|ffmpeg|twopass|S|mp4|-pix_fmt|yuv420p|-f|mp4|-movflags|+faststart|-vcodec|libvpx-vp9|-speed|0|-b:v|1000k|-maxrate:v|1500k|-bufsize:v|3000k|-minrate:v|1000k|-g|48|-hide_banner|-nostats|-row-mt|1|-tune-content|0|-tile-columns|1|-aq-mode|0|-overshoot-pct|0|-undershoot-pct|0|-auto-alt-ref|1;\
02000X264H264|ffmpeg|twopass|S|mp4|-pix_fmt|yuv420p|-f|mp4|-movflags|+faststart|-profile:v|high|-preset|slow|-vcodec|libx264|-bf|0|-refs|4|-b:v|2000k|-maxrate:v|3000k|-bufsize:v|6000k|-minrate:v|2000k|-tune|animation|-x264opts|rc-lookahead=48:keyint=96|-keyint_min|48|-g|96|-force_key_frames|expr:eq(mod(n,48),0)|-hide_banner|-nostats;\
02000AOMAV1|ffmpeg|twopass|S|mp4|-pix_fmt|yuv420p|-f|mp4|-movflags|+faststart|-vcodec|libaom-av1|-cpu-used|2|-strict|experimental|-b:v|2000k|-maxrate:v|3000k|-bufsize:v|6000k|-minrate:v|2000k|-keyint_min|48|-g|48|-hide_banner|-nostats|-row-mt|1;\
02000RAV1EAV1|ffmpeg|twopass|S|mp4|-pix_fmt|yuv420p|-f|mp4|-movflags|+faststart|-vcodec|librav1e|-speed|6|-b:v|2000k|-keyint_min|48|-g|48|-hide_banner|-nostats;\
02000SVTAV1|SvtAv1EncApp|twopass||mp4|-enc-mode|3|-film-grain|0|-adaptive-quantization|0|-rc|2|-tbr|2000000|-intra-period|23|-irefresh-type|1;\
02000SVTVP9|SvtVp9EncApp|vbr||mp4|-enc-mode|0|-tune|2|-rc|1|-tbr|2000000|-vbv-maxrate|3000000|-vbv-bufsize|6000000|-intra-period|48|-irefresh-type|2;\
02000VPXVP9|ffmpeg|twopass|S|mp4|-pix_fmt|yuv420p|-f|mp4|-movflags|+faststart|-vcodec|libvpx-vp9|-speed|0|-b:v|2000k|-maxrate:v|3000k|-bufsize:v|6000k|-minrate:v|2000k|-g|48|-hide_banner|-nostats|-row-mt|1|-tune-content|0|-tile-columns|1|-aq-mode|0|-overshoot-pct|0|-undershoot-pct|0|-auto-alt-ref|1;\
03000X264H264|ffmpeg|twopass|S|mp4|-pix_fmt|yuv420p|-f|mp4|-movflags|+faststart|-profile:v|high|-preset|slow|-vcodec|libx264|-bf|0|-refs|4|-b:v|3000k|-maxrate:v|4500k|-bufsize:v|9000k|-minrate:v|3000k|-tune|animation|-x264opts|rc-lookahead=48:keyint=96|-keyint_min|48|-g|96|-force_key_frames|expr:eq(mod(n,48),0)|-hide_banner|-nostats;\
03000AOMAV1|ffmpeg|twopass|S|mp4|-pix_fmt|yuv420p|-f|mp4|-movflags|+faststart|-vcodec|libaom-av1|-cpu-used|2|-strict|experimental|-b:v|3000k|-maxrate:v|4500k|-bufsize:v|9000k|-minrate:v|3000k|-keyint_min|48|-g|48|-hide_banner|-nostats|-row-mt|1;\
03000RAV1EAV1|ffmpeg|twopass|S|mp4|-pix_fmt|yuv420p|-f|mp4|-movflags|+faststart|-vcodec|librav1e|-speed|6|-b:v|3000k|-keyint_min|48|-g|48|-hide_banner|-nostats;\
03000SVTAV1|SvtAv1EncApp|twopass||mp4|-enc-mode|3|-film-grain|0|-adaptive-quantization|0|-rc|2|-tbr|3000000|-intra-period|23|-irefresh-type|1;\
03000SVTVP9|SvtVp9EncApp|vbr||mp4|-enc-mode|0|-tune|2|-rc|1|-tbr|3000000|-vbv-maxrate|4500000|-vbv-bufsize|9000000|-intra-period|48|-irefresh-type|2;\
03000VPXVP9|ffmpeg|twopass|S|mp4|-pix_fmt|yuv420p|-f|mp4|-movflags|+faststart|-vcodec|libvpx-vp9|-speed|0|-b:v|3000k|-maxrate:v|4500k|-bufsize:v|9000k|-minrate:v|3000k|-g|48|-hide_banner|-nostats|-row-mt|1|-tune-content|0|-tile-columns|1|-aq-mode|0|-overshoot-pct|0|-undershoot-pct|0|-auto-alt-ref|1;\
04000X264H264|ffmpeg|twopass|S|mp4|-pix_fmt|yuv420p|-f|mp4|-movflags|+faststart|-profile:v|high|-preset|slow|-vcodec|libx264|-bf|0|-refs|4|-b:v|4000k|-maxrate:v|6000k|-bufsize:v|12000k|-minrate:v|4000k|-tune|animation|-x264opts|rc-lookahead=48:keyint=96|-keyint_min|48|-g|96|-force_key_frames|expr:eq(mod(n,48),0)|-hide_banner|-nostats;\
04000AOMAV1|ffmpeg|twopass|S|mp4|-pix_fmt|yuv420p|-f|mp4|-movflags|+faststart|-vcodec|libaom-av1|-cpu-used|2|-strict|experimental|-b:v|4000k|-maxrate:v|6000k|-bufsize:v|12000k|-minrate:v|4000k|-keyint_min|48|-g|48|-hide_banner|-nostats|-row-mt|1;\
04000RAV1EAV1|ffmpeg|twopass|S|mp4|-pix_fmt|yuv420p|-f|mp4|-movflags|+faststart|-vcodec|librav1e|-speed|6|-b:v|4000k|-keyint_min|48|-g|48|-hide_banner|-nostats;\
04000SVTAV1|SvtAv1EncApp|twopass||mp4|-enc-mode|3|-film-grain|0|-adaptive-quantization|0|-rc|2|-tbr|4000000|-intra-period|23|-irefresh-type|1;\
04000SVTVP9|SvtVp9EncApp|vbr||mp4|-enc-mode|0|-tune|2|-rc|1|-tbr|4000000|-vbv-maxrate|6000000|-vbv-bufsize|12000000|-intra-period|48|-irefresh-type|2;\
04000VPXVP9|ffmpeg|twopass|S|mp4|-pix_fmt|yuv420p|-f|mp4|-movflags|+faststart|-vcodec|libvpx-vp9|-speed|0|-b:v|4000k|-maxrate:v|6000k|-bufsize:v|12000k|-minrate:v|4000k|-g|48|-hide_banner|-nostats|-row-mt|1|-tune-content|0|-tile-columns|1|-aq-mode|0|-overshoot-pct|0|-undershoot-pct|0|-auto-alt-ref|1;\
05000X264H264|ffmpeg|twopass|S|mp4|-pix_fmt|yuv420p|-f|mp4|-movflags|+faststart|-profile:v|high|-preset|slow|-vcodec|libx264|-bf|0|-refs|4|-b:v|5000k|-maxrate:v|7500k|-bufsize:v|15000k|-minrate:v|5000k|-tune|animation|-x264opts|rc-lookahead=48:keyint=96|-keyint_min|48|-g|96|-force_key_frames|expr:eq(mod(n,48),0)|-hide_banner|-nostats;\
05000AOMAV1|ffmpeg|twopass|S|mp4|-pix_fmt|yuv420p|-f|mp4|-movflags|+faststart|-vcodec|libaom-av1|-cpu-used|2|-strict|experimental|-b:v|5000k|-maxrate:v|7500k|-bufsize:v|15000k|-minrate:v|5000k|-keyint_min|48|-g|48|-hide_banner|-nostats|-row-mt|1;\
05000RAV1EAV1|ffmpeg|twopass|S|mp4|-pix_fmt|yuv420p|-f|mp4|-movflags|+faststart|-vcodec|librav1e|-speed|6|-b:v|5000k|-keyint_min|48|-g|48|-hide_banner|-nostats;\
05000SVTAV1|SvtAv1EncApp|twopass||mp4|-enc-mode|3|-film-grain|0|-adaptive-quantization|0|-rc|2|-tbr|5000000|-intra-period|23|-irefresh-type|1;\
05000SVTVP9|SvtVp9EncApp|vbr||mp4|-enc-mode|0|-tune|2|-rc|1|-tbr|5000000|-vbv-maxrate|7500000|-vbv-bufsize|15000000|-intra-period|48|-irefresh-type|2;\
05000VPXVP9|ffmpeg|twopass|S|mp4|-pix_fmt|yuv420p|-f|mp4|-movflags|+faststart|-vcodec|libvpx-vp9|-speed|0|-b:v|5000k|-maxrate:v|7500k|-bufsize:v|15000k|-minrate:v|5000k|-g|48|-hide_banner|-nostats|-row-mt|1|-tune-content|0|-tile-columns|1|-aq-mode|0|-overshoot-pct|0|-undershoot-pct|0|-auto-alt-ref|1;\
06000X264H264|ffmpeg|twopass|S|mp4|-pix_fmt|yuv420p|-f|mp4|-movflags|+faststart|-profile:v|high|-preset|slow|-vcodec|libx264|-bf|0|-refs|4|-b:v|6000k|-maxrate:v|9000k|-bufsize:v|18000k|-minrate:v|6000k|-tune|animation|-x264opts|rc-lookahead=48:keyint=96|-keyint_min|48|-g|96|-force_key_frames|expr:eq(mod(n,48),0)|-hide_banner|-nostats;\
06000AOMAV1|ffmpeg|twopass|S|mp4|-pix_fmt|yuv420p|-f|mp4|-movflags|+faststart|-vcodec|libaom-av1|-cpu-used|2|-strict|experimental|-b:v|6000k|-maxrate:v|9000k|-bufsize:v|18000k|-minrate:v|6000k|-keyint_min|48|-g|48|-hide_banner|-nostats|-row-mt|1;\
06000RAV1EAV1|ffmpeg|twopass|S|mp4|-pix_fmt|yuv420p|-f|mp4|-movflags|+faststart|-vcodec|librav1e|-speed|6|-b:v|6000k|-keyint_min|48|-g|48|-hide_banner|-nostats;\
06000SVTAV1|SvtAv1EncApp|twopass||mp4|-enc-mode|3|-film-grain|0|-adaptive-quantization|0|-rc|2|-tbr|6000000|-intra-period|23|-irefresh-type|1;\
06000SVTVP9|SvtVp9EncApp|vbr||mp4|-enc-mode|0|-tune|2|-rc|1|-tbr|6000000|-vbv-maxrate|9000000|-vbv-bufsize|18000000|-intra-period|48|-irefresh-type|2;\
06000VPXVP9|ffmpeg|twopass|S|mp4|-pix_fmt|yuv420p|-f|mp4|-movflags|+faststart|-vcodec|libvpx-vp9|-speed|0|-b:v|6000k|-maxrate:v|9000k|-bufsize:v|18000k|-minrate:v|6000k|-g|48|-hide_banner|-nostats|-row-mt|1|-tune-content|0|-tile-columns|1|-aq-mode|0|-overshoot-pct|0|-undershoot-pct|0|-auto-alt-ref|1;\
07000X264H264|ffmpeg|twopass|S|mp4|-pix_fmt|yuv420p|-f|mp4|-movflags|+faststart|-profile:v|high|-preset|slow|-vcodec|libx264|-bf|0|-refs|4|-b:v|7000k|-maxrate:v|10500k|-bufsize:v|21000k|-minrate:v|7000k|-tune|animation|-x264opts|rc-lookahead=48:keyint=96|-keyint_min|48|-g|96|-force_key_frames|expr:eq(mod(n,48),0)|-hide_banner|-nostats;\
07000AOMAV1|ffmpeg|twopass|S|mp4|-pix_fmt|yuv420p|-f|mp4|-movflags|+faststart|-vcodec|libaom-av1|-cpu-used|2|-strict|experimental|-b:v|7000k|-maxrate:v|10500k|-bufsize:v|21000k|-minrate:v|7000k|-keyint_min|48|-g|48|-hide_banner|-nostats|-row-mt|1;\
07000RAV1EAV1|ffmpeg|twopass|S|mp4|-pix_fmt|yuv420p|-f|mp4|-movflags|+faststart|-vcodec|librav1e|-speed|6|-b:v|7000k|-keyint_min|48|-g|48|-hide_banner|-nostats;\
07000SVTAV1|SvtAv1EncApp|twopass||mp4|-enc-mode|3|-film-grain|0|-adaptive-quantization|0|-rc|2|-tbr|7000000|-intra-period|23|-irefresh-type|1;\
07000SVTVP9|SvtVp9EncApp|vbr||mp4|-enc-mode|0|-tune|2|-rc|1|-tbr|7000000|-vbv-maxrate|10500000|-vbv-bufsize|21000000|-intra-period|48|-irefresh-type|2;\
07000VPXVP9|ffmpeg|twopass|S|mp4|-pix_fmt|yuv420p|-f|mp4|-movflags|+faststart|-vcodec|libvpx-vp9|-speed|0|-b:v|7000k|-maxrate:v|10500k|-bufsize:v|21000k|-minrate:v|7000k|-g|48|-hide_banner|-nostats|-row-mt|1|-tune-content|0|-tile-columns|1|-aq-mode|0|-overshoot-pct|0|-undershoot-pct|0|-auto-alt-ref|1;\
08000X264H264|ffmpeg|twopass|S|mp4|-pix_fmt|yuv420p|-f|mp4|-movflags|+faststart|-profile:v|high|-preset|slow|-vcodec|libx264|-bf|0|-refs|4|-b:v|8000k|-maxrate:v|12000k|-bufsize:v|24000k|-minrate:v|8000k|-tune|animation|-x264opts|rc-lookahead=48:keyint=96|-keyint_min|48|-g|96|-force_key_frames|expr:eq(mod(n,48),0)|-hide_banner|-nostats;\
08000AOMAV1|ffmpeg|twopass|S|mp4|-pix_fmt|yuv420p|-f|mp4|-movflags|+faststart|-vcodec|libaom-av1|-cpu-used|2|-strict|experimental|-b:v|8000k|-maxrate:v|12000k|-bufsize:v|24000k|-minrate:v|8000k|-keyint_min|48|-g|48|-hide_banner|-nostats|-row-mt|1;\
08000RAV1EAV1|ffmpeg|twopass|S|mp4|-pix_fmt|yuv420p|-f|mp4|-movflags|+faststart|-vcodec|librav1e|-speed|6|-b:v|8000k|-keyint_min|48|-g|48|-hide_banner|-nostats;\
08000SVTAV1|SvtAv1EncApp|twopass||mp4|-enc-mode|3|-film-grain|0|-adaptive-quantization|0|-rc|2|-tbr|8000000|-intra-period|23|-irefresh-type|1;\
08000SVTVP9|SvtVp9EncApp|vbr||mp4|-enc-mode|0|-tune|2|-rc|1|-tbr|8000000|-vbv-maxrate|12000000|-vbv-bufsize|24000000|-intra-period|48|-irefresh-type|2;\
08000VPXVP9|ffmpeg|twopass|S|mp4|-pix_fmt|yuv420p|-f|mp4|-movflags|+faststart|-vcodec|libvpx-vp9|-speed|0|-b:v|8000k|-maxrate:v|12000k|-bufsize:v|24000k|-minrate:v|8000k|-g|48|-hide_banner|-nostats|-row-mt|1|-tune-content|0|-tile-columns|1|-aq-mode|0|-overshoot-pct|0|-undershoot-pct|0|-auto-alt-ref|1;\
"
