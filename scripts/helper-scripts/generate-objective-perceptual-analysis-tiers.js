let tiers = [
    {
        height: 1080,
        bitrates: [10000, 9500, 9000, 8500, 8000, 7500, 7000, 6500, 6000, 5500, 5000, 4500, 4000, 3500, 3000, 2500, 2000, 1500, 1000, 500]
    },
    {
        height: 720,
        bitrates: [6000, 5500, 5000, 4500, 4000, 3500, 3000, 2500, 2000, 1500, 1000, 500]
    },
    {
        height: 480,
        bitrates: [3500, 3000, 2500, 2000, 1500, 1000, 500, 300, 200, 120]
    },
    {
        height: 360,
        bitrates: [2500, 2000, 1500, 1000, 500, 300, 200, 120]
    },
    {
        height: 240,
        bitrates: [1500, 1000, 500, 300, 200, 120]
    }
]

let cmds = [];

tiers.forEach(t => {
    // 01000X264H264|ffmpeg|twopass|S|mp4||1080|-pix_fmt|yuv420p|-f|mp4|-movflags|+faststart|-profile:v|high|-preset|slow|-vcodec|libx264|-bf|0|-refs|4|-b:v|1000k|-maxrate:v|1500k|-bufsize:v|3000k|-minrate:v|1000k|-tune|animation|-x264opts|rc-lookahead=48:keyint=96|-keyint_min|48|-g|96|-force_key_frames|expr:eq(mod(n,48),0)|-hide_banner|-nostats;
    t.bitrates.forEach(bitrate => {
        let maxRate = bitrate * 1.5;
        let bufSize = bitrate * 3;

        cmds.push(`${t.height}p${('00000'+bitrate).slice(-5)}X264H264|ffmpeg|twopass|S|mp4||${t.height}|-pix_fmt|yuv420p|-f|mp4|-movflags|+faststart|-profile:v|high|-preset|slow|-vcodec|libx264|-bf|0|-refs|4|-b:v|${bitrate}k|-maxrate:v|${maxRate}k|-bufsize:v|${bufSize}k|-minrate:v|${bitrate}k|-tune|animation|-x264opts|rc-lookahead=48:keyint=96|-keyint_min|48|-g|96|-force_key_frames|expr:eq(mod(n,48),0)|-hide_banner|-nostats;`);
    });
});

console.log(cmds.join('\\\n'));
