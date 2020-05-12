#!/usr/bin/env python2.7

import argparse
import datetime
import json
import subprocess
from os import getcwd
from os import listdir
from os import mkdir
from os.path import isfile, isdir, join, getsize
from os.path import basename
from os.path import splitext
from os import environ

environ["GDFONTPATH"] = "/usr/share/fonts/msttcorefonts/"
environ["PATH"] = "%s/FFmpeg:%s" % (getcwd(), environ["PATH"])

# results list
results = []

debug = False
preview = False
base_directory = None

ap = argparse.ArgumentParser()
ap.add_argument('-n', '--directory', dest='directory', required=True, help="Name of the tests base directory")
ap.add_argument('-d', '--debug', dest='debug', required=False, action='store_true', help="Debug")
ap.add_argument('-p', '--preview', dest='preview', required=False, action='store_true', help="Create preview videos with metrics burned in")
args = vars(ap.parse_args())

base_directory = args['directory']
debug = args['debug']
preview = args['preview']

mezz_dir = "%s/mezzanines" % base_directory
encode_dir = "%s/encodes" % base_directory
result_dir = "%s/results" % base_directory
preview_dir = "%s/preview" % base_directory

# return video timecode from seconds value
def secs2time(s):
    ms = int((s - int(s)) * 1000000)
    s = int(s)
    # Get rid of this line if s will never exceed 86400
    while s >= 24*60*60: s -= 24*60*60
    h = s / (60*60)
    s -= h*60*60
    m = s / 60
    s -= m*60
    timecode_microseconds = datetime.time(h, m, s, ms).isoformat()
    if '.' in timecode_microseconds:
        base_time, microseconds  = timecode_microseconds.split('.')
    else:
        base_time = timecode_microseconds
        microseconds = 0
    return "%s,%03d" % (base_time, int(microseconds) / 1000)


# get list of mezzanines
mezzanines = [f for f in listdir(mezz_dir)]

for m in mezzanines:
    if m[0] == '.':
        # skip .dotfiles
        continue
    # this specific mezzanines result dictionary
    result = {}
    # remove mezzanine file extension for base name of test files
    mbase = "%s" % splitext(m)[0]
    if debug:
        print "\nMezzanine %s:" % mbase

    fkey = mbase
    result_key_spacer = "%s-1000" % (fkey[:32])
    result[result_key_spacer] = {}

    # grab encode stats list for this mezzanine
    encode_stats = [f for f in listdir(encode_dir) if f.startswith(mbase) if f.endswith(".json")]
    for es in sorted(encode_stats):
        # remove extensions, both .json and _data
        ebase = "%s" % splitext(splitext(es)[0])[0]
        elabel = ebase[len(mbase):]
        if len(elabel[1:].split('_')) > 2 or (len(mbase) > len(ebase)) or elabel[0] != '_':
            if debug:
                print "Warning: Wrong encode status file for %s: %s" % (mbase, es)
                print "\t- %s, %s, %s, %s" % (m, ebase, mbase, elabel[1:])
            continue
        n, l = elabel[1:].split('_')
        # turn alphabet character into an index number for human readable label
        if len(l) == 3:
            hindex = (ord(l[0].lower()) - 96) - 1
            hindex += (ord(l[1].lower()) - 96) - 1
            hindex += (ord(l[2].lower()) - 96) - 1
        elif len(l) == 2:
            hindex = (ord(l[0].lower()) - 96) - 1
            hindex += (ord(l[1].lower()) - 96) - 1
        elif len(l) == 1:
            hindex = (ord(l.lower()) - 96) - 1
        else:
            print "ERROR: Invalid index letter %s" % l
            continue
        # test label as setup in encode.py
        hlabel = n

        # get encode stats from encode json data
        bitrate = 0
        filesize = 0
        duration = 0.0
        height = 0
        width = 0
        framerate = 0.0
        with open("%s/%s" % (encode_dir, es)) as encode_stats_json:
            try:
                ed = json.load(encode_stats_json)
                # case of identify job output w/out encoding
                if 'video' in ed:
                    ed = ed['video']
                if 'vbitrate' in ed:
                    bitrate = int(ed['vbitrate'])
                if 'filesize' in ed:
                    filesize = int(ed['filesize'])
                if 'duration' in ed:
                    duration = float(ed['duration'])
                if 'framerate' in ed:
                    framerate= float(ed['framerate'])
                if 'height' in ed:
                    height = float(ed['height'])
                if 'width' in ed:
                    width = float(ed['width'])
            except Exception, e:
                if debug:
                    print "error: %s %s" % (es, e)

        # Combine PHQM segment scores with VMAF
        result_base = result_dir + '/' + ebase
        phqm_stats = result_base + "_phqm.data"
        phqm_stdout = result_base + "_phqm.stdout"
        vmaf_data = result_base + "_vmaf.data"
        phqm_scd = result_base + "_phqm.scd"
        preview_srt = result_base + "_preview.srt"

        sections = []
        try:
            # scene change segments avg score calc
            vd = {}
            if isfile(vmaf_data):
                with open(vmaf_data) as vmaf_json:
                    # get vmaf data
                    vd = json.load(vmaf_json)

                # create srt file for metrics OSD
                if isfile(phqm_stats) and (not isfile(preview_srt) or getsize(preview_srt) < 0):
                    psnr_metrics = None
                    with open(phqm_stats, "r") as f:
                        psnr_metrics = f.readlines()
                    psnr_metrics = [x.strip() for x in psnr_metrics]
                    with open(preview_srt, "w") as f:
                        for l in psnr_metrics:
                            parts = l.split(' ')
                            frame = int(parts[0].split(':')[1])
                            phqm_avg = float(parts[1].split(':')[1])
                            scd = float(parts[4].split(':')[1])
                            #psnr_avg = parts[9].split(':')[1]
                            start_seconds = (1.0/float(framerate)) * float(frame)
                            end_seconds = (1.0/float(framerate)) * (float(frame) + .9)
                            start_time = secs2time(start_seconds)
                            end_time = secs2time(end_seconds)
                            vmaf = float(vd["frames"][frame-1]["metrics"]["vmaf"])
                            msssim = float(vd["frames"][frame-1]["metrics"]["ms_ssim"])
                            psnr = float(vd["frames"][frame-1]["metrics"]["psnr"])
                            srt_line = "%08d\n%s --> %s\nTIMECODE[%s] SCD[%0.1f] PHQM[%0.3f] VMAF[%0.1f] PSNR[%0.1f] SSIM[%0.3f]\n\n" % (frame,
                                    start_time, end_time, start_time, scd, phqm_avg, vmaf, psnr, msssim)
                            f.write(srt_line)

                if not isfile(phqm_scd) and isfile(phqm_stdout):
                    # read stdout with scenes segmented into frame ranges
                    with open(phqm_stdout) as phqm_data:
                        for i, line in enumerate(phqm_data):
                            if "ImgHashScene:" in line:
                                parts = line.split(' ')
                                start_frame, end_frame = parts[4].split(':')[1].split('-')
                                start_frame = int(start_frame)
                                end_frame = int(end_frame)
                                phqm_avg = float(parts[5].split(':')[1])
                                phqm_min = 0.0
                                phqm_max = 0.0
                                sft = 0.0
                                hft = 0.0
                                if len(parts) >= 8:
                                    phqm_min = float(parts[6].split(':')[1])
                                    phqm_max = float(parts[7].split(':')[1])
                                if len(parts) >= 11:
                                    hft = float(parts[9].split(':')[1])
                                    sft = float(parts[10].split(':')[1])
                                vmaf_total = 0.0
                                psnr_total = 0.0
                                ms_ssim_total = 0.0
                                for n, frame in enumerate(vd["frames"][start_frame-1:end_frame-1]):
                                    vmaf_total += float(frame["metrics"]["vmaf"])
                                    psnr_total += float(frame["metrics"]["psnr"])
                                    ms_ssim_total += float(frame["metrics"]["ms_ssim"])
                                #print "VMAF end_frame: %d start_frame: %d" % (start_frame, end_frame)
                                vmaf_avg = vmaf_total
                                psnr_avg = psnr_total
                                ms_ssim_avg = ms_ssim_total
                                if end_frame > start_frame:
                                    # if last frame was a scene change we may have only 1 frame in a section
                                    vmaf_avg = vmaf_total / (end_frame - start_frame)
                                    psnr_avg = psnr_total / (end_frame - start_frame)
                                    ms_ssim_avg = ms_ssim_total / (end_frame - start_frame)
                                section = {}
                                section["number"] = i
                                section["nframes"] = end_frame - start_frame
                                section["start_frame"] = start_frame
                                section["end_frame"] = end_frame
                                section["hamm_avg"] = phqm_avg
                                section["hamm_min"] = phqm_min
                                section["hamm_max"] = phqm_max
                                section["phqm_avg"] = min(100.0, 100.0 - (20.0 * min(phqm_avg, 5.0)))
                                section["vmaf_avg"] = vmaf_avg
                                section["ssim_avg"] = ms_ssim_avg
                                section["psnr_avg"] = psnr_avg
                                section["sft"] = sft
                                section["hft"] = hft
                                sections.append(section)
                        # write combined metrics to a json file for scd
                        with open(phqm_scd, "w") as f:
                            f.write("%s" % json.dumps(sections, sort_keys=True))
        except Exception, e:
            print "Error opening %s: %s" % (vmaf_data, e)

        # read scd file if it was created
        scenes = []
        if isfile(phqm_scd):
            with open(phqm_scd, "r") as scd_data:
                sections = json.load(scd_data)
                video_files = []
                for i, s in enumerate(sections):
                    mdetail = "%03d). %06d-%06d hamm:%0.3f min:%0.2f max:%0.2f phqm:%0.2f vmaf:%0.2f psnr:%0.2f ssim:%0.2f sft:%0.3f hft:%0.3f" % (i,
                            s["start_frame"], s["end_frame"],
                            s["hamm_avg"], s["hamm_min"], s["hamm_max"], s["phqm_avg"], s["vmaf_avg"], s["psnr_avg"], s["ssim_avg"], s["sft"], s["hft"])
                    scenes.append(mdetail)
                    image_dir_base = preview_dir + "/" + ebase + "_" + "%06d-%06d" % (s["start_frame"], s["end_frame"])
                    image_dir_period = image_dir_base + "/" + "images"
                    video_dir_base = preview_dir + "/" + ebase + "/" + "videos"
                    video_dir_period = video_dir_base + "/" + "%03d_%06d-%06d" % (i+1, s["start_frame"], s["end_frame"])
                    if not isdir(preview_dir):
                        mkdir(preview_dir)
                    if not isdir(image_dir_base):
                        mkdir(image_dir_base)
                    if not isdir("%s/%s" % (preview_dir, ebase)):
                        mkdir("%s/%s" % (preview_dir, ebase))
                        mkdir("%s/%s/videos" % (preview_dir, ebase))

                    # create a directory for the images in the frame range
                    if preview and not isdir(image_dir_period):
                        mkdir(image_dir_period)

                        # ffmpeg -i mezzanine -vf select='between(n\,%d\,%d),setpts=PTS-STARTPTS' image_dir_period/%08d.jpg
                        # drawtext=text='Test Text':fontcolor=white:fontsize=75:x=1002:y=100:
                        # box=1:boxcolor=black@0.7
                        subprocess.call(['ffmpeg', '-hide_banner', '-y', '-nostdin', '-nostats', '-loglevel', 'error',
                                '-i', "%s/%s" % (mezz_dir, m), '-vf',
                                "select='between(n\,%d\,%d)',setpts=PTS-STARTPTS,drawtext=text='%s':fontcolor=white:box=1:boxcolor=black@0.7:fontsize=28:x=5:y=5" % (s["start_frame"], s["end_frame"], mdetail.replace(':', ' ').replace(')', '')),
                                '-pix_fmt', 'yuv420p',
                                "%s/%%08d.jpg" % image_dir_period])
                    # create video segment with stats burned in
                    if preview and not isfile("%s.mp4" % video_dir_period):
                        subprocess.call(['ffmpeg', '-hide_banner', '-y', '-nostdin', '-nostats', '-loglevel', 'error',
                                '-i', "%s/%s" % (mezz_dir, m), '-vf',
                                "select='between(n\,%d\,%d)',setpts=PTS-STARTPTS,drawtext=text='%s':fontcolor=white:box=1:boxcolor=black@0.7:fontsize=28:x=5:y=5" % (s["start_frame"], s["end_frame"], mdetail.replace(':', ' ').replace(')', '')),
                                '-pix_fmt', 'yuv420p', '-an',
                                "%s.mp4" % video_dir_period])

                    # save video segment for concatenation later
                    video_files.append("%s.mp4" % video_dir_period)

                    video_concat = preview_dir + "/" + ebase + ".mp4"
                    if preview and not isfile(video_concat) and i == (len(sections)-1):
                        # last segment, concatenate them all
                        #
                        # ffmpeg -i segment[0] -i segment[1] -i segment[2] -filter_complex \
                        #      '[0:0] [1:0] [2:0] concat=n=3:v=1:a=0 [v]' \
                        #            -map '[v]' output.mp4
                        cmd = ['ffmpeg', '-hide_banner', '-y', '-nostdin', '-nostats',
                                    '-loglevel', 'error']
                        for sfile in video_files:
                            # input files
                            cmd.append('-i')
                            cmd.append(sfile)
                        cmd.append('-filter_complex')
                        filter_str = ""
                        for order, sfile in enumerate(video_files):
                            # input streams per file
                            filter_str = filter_str + "[%d:0] " % (order)
                        filter_str = filter_str + "concat=n=%d:v=1:a=0,subtitles=%s [v]" % (len(sections), preview_srt)
                        cmd.append(filter_str)
                        cmd.append('-map')
                        cmd.append('[v]')
                        cmd.append(video_concat)

                        if debug:
                            print "Running cmd: %r" % cmd
                        subprocess.call(cmd)

        # grab MSU results list for this mezzanine
        metrics = [f for f in listdir(result_dir) if f.startswith(ebase) if f.endswith(".json")]
        phqm = 0.0
        vmaf = 0.0
        psnr = 0.0
        ssim = 0.0
        speed = 0.0
        pfhd = 0.0
        for ms in metrics:
            # base filename per metric type
            rbase = "%s" % splitext(ms)[0]
            # metric label for type of score
            label = rbase[len(ebase):][1:]
            score = None
            with open("%s/%s" % (result_dir, ms)) as result_stats_json:
                try:
                    rd = json.load(result_stats_json)
                    # get avg score from MSU results
                    if 'avg' in rd:
                        score = rd['avg'][0]
                    # encoding speed (system dependent)
                    if label == 'speed' and 'speed' in rd:
                        speed = float(rd['speed'])
                except Exception, e:
                    if debug:
                        print "Bad stats file: %s" % result_stats_json
                    continue # skip this, probably truncated in progress writing
            # save score as type
            if score:
                if label == 'phqm':
                    phqm = float(score)
                if label == 'pfhd':
                    pfhd = float(score)
                if label == 'vmaf':
                    vmaf = float(score)
                elif label == 'msssim':
                    ssim = float(score)
                elif label == 'psnr':
                    psnr = float(score)
        result_key = "%s-%s_%s" % (fkey[:32], str("%0.3f" % vmaf).replace('.','-'), elabel[1:])
        result[result_key] = {}

        print " %s:" % result_key
        print "  Encode [%s]:" % elabel
        print "    Stats: {bitrate: %d, filesize: %d, duration: %0.2f}" % (bitrate, filesize, duration)
        # pick out specific codec values we are testing
        result[result_key]['bitrate'] = bitrate
        result[result_key]['filesize'] = filesize
        result[result_key]['duration'] =  duration
        result[result_key]['mezzanine'] = fkey
        result[result_key]['label'] = hlabel

        phqm_normalized = min(100, (100 - (min(phqm, 5) * 20.0)))
        print "   Metrics: {speed: %0.2f, pfhd: %0.2f hamm: %0.2f phqm: %0.2f vmaf: %0.2f, ssim: %0.2f, psnr: %0.2f}" % (speed,
                                pfhd, phqm, phqm_normalized, vmaf, ssim, psnr)
        for s in scenes:
            print "    %s" % s

        result[result_key]['speed'] =  speed
        result[result_key]['phqm'] = "%0.3f" % phqm_normalized
        result[result_key]['hamm'] = "%0.3f" % phqm
        result[result_key]['vmaf'] = "%0.3f" % vmaf
        result[result_key]['ssim'] = "%0.3f" % ssim
        result[result_key]['psnr'] = "%0.3f" % psnr
        result[result_key]['pfhd'] = "%0.3f" % pfhd

    # append result to total results for all mezzanines
    if float(vmaf) > 0 and float(ssim) > 0 and float(psnr) > 0 and float(phqm) >= 0:
        results.append(result)
    elif debug:
        print "Skipping: %s" % m

with open("%s/stats.json" % base_directory, "w") as f:
    f.write("%s" % json.dumps(results, sort_keys=True))

results_avg = {}
for result in sorted(results):
    for label, data in sorted(result.iteritems()):
        bitrate = 0
        phqm = 0.0
        vmaf = 0.0
        ssim = 0.0
        psnr = 0.0
        pfhd = 0.0
        test_label = label
        speed = 0
        for key, value in data.iteritems():
            if key == "bitrate":
                bitrate = value
            elif key == "phqm":
                phqm = float(value)
            elif key == "pfhd":
                pfhd = float(value)
            elif key == "vmaf":
                vmaf = float(value)
            elif key == "psnr":
                psnr = float(value)
            elif key == "ssim":
                ssim = float(value)
            elif key == "label":
                test_label = value
            elif key == "speed":
                speed = int(value)

        # setup test label if not in the dict yet
        if not test_label in results_avg:
            results_avg[test_label] = {}
            results_avg[test_label]['psnr'] = []
            results_avg[test_label]['phqm'] = []
            results_avg[test_label]['pfhd'] = []
            results_avg[test_label]['vmaf'] = []
            results_avg[test_label]['ssim'] = []
            results_avg[test_label]['bitrate'] = []
            results_avg[test_label]['speed'] = []

        # collect values into lists
        results_avg[test_label]['psnr'].append(psnr)
        results_avg[test_label]['pfhd'].append(pfhd)
        results_avg[test_label]['phqm'].append(phqm)
        results_avg[test_label]['vmaf'].append(vmaf)
        results_avg[test_label]['ssim'].append(ssim)
        results_avg[test_label]['bitrate'].append(bitrate)
        results_avg[test_label]['speed'].append(speed)

# create dat file for CSV or GNUPlot
body = "# test\tpfhd\tphqm\tvmaf\tssim\tpsnr\tbitrate\tspeed\n"
for label, data in sorted(results_avg.iteritems()):
    bitrate = 0
    vmaf = 0.0
    phqm = 0.0
    pfhd = 0.0
    ssim = 0.0
    psnr = 0.0
    speed = 0
    for key, value in data.iteritems():
        if key == "bitrate":
            for b in value:
                bitrate += int(b)
            bitrate = int(bitrate / len(value))
        elif key == "speed":
            for b in value:
                speed += int(b)
            speed = int(speed / len(value))
        elif key == "phqm":
            for b in value:
                phqm += float(b)
            phqm = float(phqm/ len(value))
        elif key == "pfhd":
            for b in value:
                pfhd += float(b)
            pfhd = float(pfhd/ len(value))
        elif key == "vmaf":
            for b in value:
                vmaf += float(b)
            vmaf = float(vmaf / len(value))
        elif key == "psnr":
            for b in value:
                psnr += float(b)
            psnr = float(psnr / len(value))
        elif key == "ssim":
            for b in value:
                ssim += float(b)
            ssim = float(ssim / len(value))
    if vmaf > 0 and ssim > 0 and psnr > 0 and phqm >= 0:
        body =  "%s%s\t%0.3f\t%0.3f\t%0.3f\t%0.3f\t%0.3f\t%d\t%d\n" % (body, label, pfhd, phqm, vmaf, ssim, psnr, bitrate, speed)

with open("%s/stats.csv" % base_directory, "w") as f:
    f.write("%s" % body)

# copy gnuplot config template into the test base directory
gpdata = []
with open("stats.gp", "r") as f:
    gpdata = f.readlines()
with open("%s/stats.gp" % base_directory, "w") as f:
    for l in gpdata:
        l = l.replace("__TITLE__", "%s" % base_directory)
        f.write("%s" % l)

if len(results) > 0:
    subprocess.call(['gnuplot', '--persist', "stats.gp"], cwd="%s" % base_directory)

