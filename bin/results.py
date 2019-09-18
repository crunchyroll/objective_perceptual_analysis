#!/usr/bin/python2.7

import argparse
import json
import subprocess
from os import listdir
from os import mkdir
from os.path import isfile, isdir, join
from os.path import basename
from os.path import splitext
from os import environ

environ["GDFONTPATH"] = "/usr/share/fonts/msttcorefonts/"

# results list
results = []

debug = False
base_directory = None

ap = argparse.ArgumentParser()
ap.add_argument('-n', '--directory', dest='directory', required=True, help="Name of the tests base directory")
ap.add_argument('-d', '--debug', dest='debug', required=False, action='store_false', help="Debug")
args = vars(ap.parse_args())

base_directory = args['directory']
debug = args['debug']

mezz_dir = "%s/mezzanines" % base_directory
encode_dir = "%s/encodes" % base_directory
result_dir = "%s/results" % base_directory

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
            except Exception, e:
                if debug:
                    print "error: %s %s" % (es, e)

        # Combine PHQM segment scores with VMAF
        result_base = result_dir + '/' + ebase
        phqm_stdout = result_base + "_phqm.stdout"
        vmaf_data = result_base + "_vmaf.data"
        phqm_scd = result_base + "_phqm.scd"

        if not isfile(phqm_scd) and isfile(phqm_stdout) and isfile(vmaf_data):
            sections = []
            try:
                # scene change segments avg score calc
                vd = {}
                with open(vmaf_data) as vmaf_json:
                    # get vmaf data
                    vd = json.load(vmaf_json)
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
                            if len(parts) >= 9:
                                phqm_min = float(parts[6].split(':')[1])
                                phqm_max = float(parts[7].split(':')[1])
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
                            sections.append(section)
                    # write combined metrics to a json file for scd
                    with open(phqm_scd, "w") as f:
                        f.write("%s" % json.dumps(sections, sort_keys=True))
            except Exception, e:
                print "Error opening %s: %s" % (vmaf_data, e)

        # read scd file if it was created
        if isfile(phqm_scd):
            with open(phqm_scd, "r") as scd_data:
                sections = json.load(scd_data)
                for i, s in enumerate(sections):
                    mdetail = "%03d). %06d-%06d hamm:%0.3f min:%0.2f max:%0.2f phqm:%0.2f vmaf:%0.2f psnr:%0.2f ssim:%0.2f" % (i,
                            s["start_frame"], s["end_frame"],
                            s["hamm_avg"], s["hamm_min"], s["hamm_max"], s["phqm_avg"], s["vmaf_avg"], s["psnr_avg"], s["ssim_avg"])
                    print mdetail
                    image_dir_period = result_dir + "/" + ebase + "_" + "%06d-%06d" % (s["start_frame"], s["end_frame"])

                    # create a directory for the images in the frame range
                    if not isdir(image_dir_period):
                        mkdir(image_dir_period)

                        # ffmpeg -i mezzanine -vf select='between(n\,%d\,%d),setpts=PTS-STARTPTS' image_dir_period/%08d.jpg
                        # drawtext=text='Test Text':fontcolor=white:fontsize=75:x=1002:y=100:
                        # box=1:boxcolor=black@0.7
                        subprocess.call(['FFmpeg/ffmpeg', '-hide_banner', '-y', '-nostdin', '-nostats', '-loglevel', 'error',
                                '-i', "%s/%s" % (mezz_dir, m), '-vf',
                                "select='between(n\,%d\,%d)',setpts=PTS-STARTPTS,drawtext=text='%s':fontcolor=white:box=1:boxcolor=black@0.7:fontsize=28:x=5:y=5" % (s["start_frame"], s["end_frame"], mdetail.replace(':', ' ').replace(')', '')),
                                '-pix_fmt', 'yuv420p',
                                "%s/%%08d.jpg" % image_dir_period])
                        subprocess.call(['FFmpeg/ffmpeg', '-hide_banner', '-y', '-nostdin', '-nostats', '-loglevel', 'error',
                                '-i', "%s/%s" % (mezz_dir, m), '-vf',
                                "select='between(n\,%d\,%d)',setpts=PTS-STARTPTS,drawtext=text='%s':fontcolor=white:box=1:boxcolor=black@0.7:fontsize=28:x=5:y=5" % (s["start_frame"], s["end_frame"], mdetail.replace(':', ' ').replace(')', '')),
                                '-pix_fmt', 'yuv420p', '-an',
                                "%s.mp4" % image_dir_period])

        # grab MSU results list for this mezzanine
        metrics = [f for f in listdir(result_dir) if f.startswith(ebase) if f.endswith(".json")]
        phqm = 0.0
        vmaf = 0.0
        psnr = 0.0
        ssim = 0.0
        speed = 0.0
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
                if label == 'vmaf':
                    vmaf = float(score)
                elif label == 'msssim':
                    ssim = float(score)
                elif label == 'psnr':
                    psnr = float(score)
        result_key = "%s-%s_%s" % (fkey[:32], str("%0.3f" % vmaf).replace('.','-'), elabel[1:])
        result[result_key] = {}

        if debug: 
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
        if debug:
            print "   Metrics: {speed: %0.2f, hamm: %0.2f phqm: %0.2f vmaf: %0.2f, ssim: %0.2f, psnr: %0.2f}" % (speed,
                                phqm, phqm_normalized, vmaf, ssim, psnr)
        result[result_key]['speed'] =  speed
        result[result_key]['phqm'] = "%0.3f" % phqm_normalized
        result[result_key]['hamm'] = "%0.3f" % phqm
        result[result_key]['vmaf'] = "%0.3f" % vmaf
        result[result_key]['ssim'] = "%0.3f" % ssim
        result[result_key]['psnr'] = "%0.3f" % psnr

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
        test_label = label
        speed = 0
        for key, value in data.iteritems():
            if key == "bitrate":
                bitrate = value
            elif key == "phqm":
                phqm = float(value)
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
            results_avg[test_label]['vmaf'] = []
            results_avg[test_label]['ssim'] = []
            results_avg[test_label]['bitrate'] = []
            results_avg[test_label]['speed'] = []

        # collect values into lists
        results_avg[test_label]['psnr'].append(psnr)
        results_avg[test_label]['phqm'].append(phqm)
        results_avg[test_label]['vmaf'].append(vmaf)
        results_avg[test_label]['ssim'].append(ssim)
        results_avg[test_label]['bitrate'].append(bitrate)
        results_avg[test_label]['speed'].append(speed)

# create dat file for CSV or GNUPlot
body = "# test\tphqm\tvmaf\tssim\tpsnr\tbitrate\tspeed\n"
for label, data in sorted(results_avg.iteritems()):
    bitrate = 0
    vmaf = 0.0
    phqm = 0.0
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
        body =  "%s%s\t%0.3f\t%0.3f\t%0.3f\t%0.3f\t%d\t%d\n" % (body, label, phqm, vmaf, ssim, psnr, bitrate, speed)

with open("%s/stats.dat" % base_directory, "w") as f:
    f.write("%s" % body)

# copy gnuplot config template into the test base directory
gpdata = ""
with open("stats.gp", "r") as f:
    gpdata = f.read()
with open("%s/stats.gp" % base_directory, "w") as f:
    f.write("%s" % gpdata)

if len(results) > 0:
    subprocess.call(['gnuplot', '--persist', "stats.gp"], cwd="%s" % base_directory)

