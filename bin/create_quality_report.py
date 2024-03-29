#!/usr/bin/env python3

import argparse
from os import getcwd
from os import listdir
from os import environ
from os import path
import subprocess
import json

VIVICT_URLBASE = "http://svt.github.io/vivict/"
STORAGE_URLBASE = "http://your-http-storage.com"
REFERENCE_LABEL = "08000X264H264"
CURRENT_DIR = getcwd()
RESULTS_SCRIPT = "results.py"
environ["PATH"] = "bin/:%s" % (environ["PATH"])


ap = argparse.ArgumentParser()
ap.add_argument('-n', '--directory', dest='directory', required=True, help="Name of the tests base directory")
ap.add_argument('-v', '--vivict_urlbase', dest='vivict_urlbase', default=VIVICT_URLBASE, required=False, help="Web server running vivict player")
ap.add_argument('-s', '--storage_urlbase', dest='storage_urlbase', default=STORAGE_URLBASE, required=False, help="Web server with videos accessible")
ap.add_argument('-r', '--reference_label', dest='reference_label', default=REFERENCE_LABEL, required=False, help="Reference label to use for comparisons")
ap.add_argument('-d', '--debug', dest='debug', required=False, action='store_true', help="Debug")
ap.add_argument('-q', '--quality', dest='quality', required=False, default=95.0, help="VMAF Quality Percentage minimum, 95.0 is the default")
ap.add_argument('-e', '--exclude', dest='exclude', required=False, action='store_true', help="Exclude low quality, only show ones that pass minimum")
ap.add_argument('-is', '--ignore_scenes', dest='ignore_scenes', required=False, action='store_true', help="Ignore scene scores when judging quality for bitrate ladder inclusion")
args = vars(ap.parse_args())

base_directory = args['directory']
vivict_urlbase = args['vivict_urlbase']
storage_urlbase = args['storage_urlbase']
reference_label = args['reference_label']
debug = args['debug']
minimum_quality = float(args['quality'])
exclude_quality = args['exclude']
ignore_scenes = not args['ignore_scenes']

encode_dir = "%s/encodes" % base_directory
encodes = [f for f in listdir(encode_dir)]
results = subprocess.check_output(['results.py', '-n', base_directory])
encode = None
label = None
stats = None
metrics = None
encode_list = {}
reference_encode = None
for r in results.splitlines():
    if r[1] != ' ':
        encode = r[1:].replace(':', '')
        if debug:
            print("Encode: %s" % encode)
        encode_list[encode] = {}
    elif "Encode [" in r:
            label = r[11:].replace("]", "").replace("[", "").replace(":", "")
            if debug:
                print("Label: %s" % label)
            encode_list[encode]["label"] = label

            # get encode
            encode_file = None
            for e in sorted(encodes):
                if e[0] == '.' or e.split(".")[1] != "mp4":
                        # skip .dotfiles
                        continue
                if label in e and encode[0:len(encode)-(len(label))] in e:
                    encode_file = e
            # get mezzanine
            for e in sorted(encodes):
                if e[0] == '.' or e.split(".")[1] != "mp4":
                        # skip .dotfiles
                        continue
                #print "encode: %s label: %s" % (encode, label)
                if reference_label in e and encode[0:len(encode)-(len(label))] in e and e[len(e)-4:] == ".mp4":
                    reference_encode = e
                    encode_list[encode]["reference"] = e
                    encode_list[encode]["encode_file"] = encode_file

    elif "Stats: " in r:
        stats = r.replace("    Stats: ", "")
        if debug:
            print("Stats: %s" % (stats))
        encode_list[encode]["stats"] = stats
    elif "Metrics: " in r:
        metrics = r.replace("   Metrics: ", "")
        if debug:
            print("Metrics: %s" % (metrics))
        encode_list[encode]["metrics"] = metrics
    else:
        if debug:
            print("Scene: %s" % r)
        if "scenes" not in encode_list[encode]:
            encode_list[encode]["scenes"] = []
        encode_list[encode]["scenes"].append(r[10:])

if debug:
    print("Encode List: %s" % json.dumps(encode_list, indent=4))

quality_good = {}

print("<html><title>Encode Quality Comparison %s</title>" % base_directory)
print("<head><style>table, th, td, h1, caption { border: 3px solid #ff6600; padding: 5px; border-collapse: collapse; vertical-align: top; color: white; white-space:nowrap; }\nbody { color: white; background-color: black; }\na:link, a:visited { color: yellow; }</style></head>")
print("<body>")
print("<table><caption style=\"background-color: #000000; \"><h1><a style=\"color: #eeeeee; \" href=\"%s/%s/stats.json\">Encode Quality Comparsion (%s)</a></h1>" % (storage_urlbase, base_directory, base_directory))
print("<a href=\"ladders.json\">Bitrate Ladders Raw Json Data</a><br><hr>")
print("<a href=\"%s/%s/stats.jpg\"><img src=\"%s/%s/stats.jpg\" width=640 height=380></a></caption>" % (storage_urlbase, base_directory, storage_urlbase, base_directory))
print("<tr><th style=\"background-color:#ff6600;color:#000000\">Encode</th><th style=\"background-color:#ff6600;color:#000000\">scenes</th></tr>")
for encode, data in sorted(encode_list.items()):
    metadata_file = "%s/encodes/%s.mp4_data.json" % (base_directory, encode)
    metadata = "None"
    if path.isfile(metadata_file):
        with open(metadata_file, 'r') as mf:
            metadata = mf.read()
    metadata_json = json.loads(metadata)
    metrics_json = json.loads(data["metrics"])
    total_vmaf_score = float(metrics_json["vmaf"])
    total_pdiff_score = float(metrics_json["hamm"])
    total_psnr_score = float(metrics_json["psnr"])
    data["pdiff"] = total_pdiff_score
    data["vmaf"] = total_vmaf_score
    data["psnr"] = total_psnr_score
    # check if this matches our minimum quality expectations
    if exclude_quality and total_vmaf_score < minimum_quality:
        continue
    if debug:
        print("Encode: %s" % encode)
        print("Mezzanine: %s" % data["reference"])
        # {bitrate: 778, filesize: 10649765, duration: 109.48}
        print("Stats: %s" % data["stats"])
        #   {speed: 416.00, pfhd: 1.97 hamm: 1.66 phqm: 66.79 vmaf: 96.08, ssim: 1.00, psnr: 47.33}
        print("Metrics: %s" % data["metrics"])

    print("<tr>")
    if "reference" not in data:
        data["reference"] = "Not-Finished-Yet"

    lowest_vmaf = total_vmaf_score
    if "scenes" not in data:
        data["scenes"] = []
    else:
        for scene in data["scenes"]:
            vmaf_score = float(scene.split(" ")[5].split(":")[1])
            # get lowest VMAF scene
            if vmaf_score < lowest_vmaf:
                lowest_vmaf = vmaf_score
    bcolor = "green"
    fcolor = "black"
    if total_vmaf_score < (minimum_quality - 10):
        bcolor = "purple"
        fcolor = "white"
    elif total_vmaf_score < (minimum_quality - 10):
        bcolor = "red"
        fcolor = "white"
    elif total_vmaf_score < (minimum_quality - 5):
        bcolor = "orange"
    elif total_vmaf_score < minimum_quality:
        bcolor = "yellow"
    elif lowest_vmaf < minimum_quality:
        # avg total score ok but individual scenes not ok
        bcolor = "yellow"
    print("<td><table><tr style=\"vertical-align:top\">")
    print("<td style=\"background-color:%s;color:%s\"><strong>[%0.2f%%] Encode: (%s)</strong></td>" % (bcolor, fcolor, total_vmaf_score, data["label"]))
    print("<td><a href=%s>%s</a></td></tr><tr>" % ("%s?leftVideoUrl=%s&rightVideoUrl=%s&hideSourceSelector=1&hideHelp=1&score=0&quality=" % (vivict_urlbase, "%s/%s/%s" % (storage_urlbase, "%s/encodes" % base_directory, data["reference"]), "%s/%s/%s" % (storage_urlbase, "%s/encodes" % base_directory, "%s.mp4" % encode)), encode))
    print("<td><strong>Reference: (%s)</strong></td><td>%s</td></tr><tr>" % (reference_label, data["reference"]))
    # {"video": {"framerate": 23.976, "vbitrate": 102, "height": 240, "width": 427, "filesize": 1397598, "duration": 109.485}}
    print("<td><strong>Mediainfo: </strong></td><td>%s</td></tr><tr>" % (json.dumps(json.loads(metadata), indent=4).replace("\n", "<br>").replace(" ", "&nbsp;")))
    print("<td><strong>Stats:</strong></td><td>%s</td></tr><tr><td><strong>Metrics:</strong></td><td>%s</td></tr></table></td><td><table>" % (json.dumps(json.loads(data["stats"]), indent=4).replace("\n", "<br>").replace(" ", "&nbsp;"), json.dumps(json.loads(data["metrics"]), indent=4).replace("\n", "<br>").replace(" ", "&nbsp;")))
    vmaf_good = True
    for scene in data["scenes"]:
        start_frame, end_frame = scene.split(" ")[0].split("-")
        framerate = float(metadata_json["video"]["framerate"])
        position = int(float(start_frame) / framerate)
        duration = int(float(int(end_frame) - int(start_frame)) / framerate)
        vmaf_score = float(scene.split(" ")[5].split(":")[1])

        # %s?leftVideoUrl=%s&rightVideoUrl=%s&hideSourceSelector=1&hideHelp=1&position=10&duration=10
        if debug:
            print("Scene: %s" % scene)
        url = "%s?leftVideoUrl=%s&rightVideoUrl=%s&hideSourceSelector=1&hideHelp=1&position=%d&duration=%d&score=0&quality=" % (vivict_urlbase,
                                                                                                           "%s/%s/%s" % (storage_urlbase, "%s/encodes" % base_directory, data["reference"]),
                                                                                                           "%s/%s/%s" % (storage_urlbase, "%s/encodes" % base_directory, "%s.mp4" % encode),
                                                                                                           position, duration)
        if debug:
            print("Url: %s" % url)
        bcolor = "green"
        fcolor = "black"
        lcolor = "blue"
        if vmaf_score < (minimum_quality - 10):
            bcolor = "purple"
            fcolor = "white"
            lcolor = "yellow"
        elif vmaf_score < (minimum_quality - 10):
            bcolor = "red"
            fcolor = "white"
            lcolor = "yellow"
        elif vmaf_score < (minimum_quality - 5):
            bcolor = "orange"
        elif vmaf_score < minimum_quality:
            bcolor = "yellow"
            lcolor = "red"
        if vmaf_score < minimum_quality:
            vmaf_good = False
        print("<tr><td style=\"background-color:%s;color:%s\"><strong>%d-%ds [%0.2f%%]:</strong> <a style=\"color:%s;visited:%s\" href=%s>%s</a></td></tr>" % (bcolor,
                                                                                                                                 fcolor, position, position+duration,
                                                                                                                                 vmaf_score, lcolor, lcolor, url, ": ".join(scene.split(" ")[1:8])))
    print("</table></td></tr>")
    if data["reference"] not in quality_good:
        quality_good[data["reference"]] = []
    if (vmaf_good or ignore_scenes) and data["vmaf"] >= minimum_quality:
        quality_good[data["reference"]].append(data["label"] + "_VMAF_[%0.2f:%0.2f:%0.2f]" % (data["vmaf"], data["pdiff"], data["psnr"]))

print("</table>")

print("<br>")
print("<table style=\"white-space:nowrap\">")
print("<caption><h1>Encodes that pass Quality levels</h1></caption>")
levels = {}
ladder_file = "%s/ladders.json" % base_directory
ladder_json = {}
for k, v in sorted(iter(quality_good.items()), reverse = True):
    if k not in ladder_json:
        # mezzanine indexed bitrate ladder in json
        ladder_json[k.rsplit("_", 1)[0]] = {}
    print("<tr><table><tr><th><h1>Mezzanine: %s</h1></th></tr>" % k)
    for q in sorted(v, reverse = False):
        if k + ":" + q[:3] not in levels and reference_label not in q:
            print("<tr><td style=\"background-color:green;color:black\"><h2>PASS: %s<h2></td></tr>" % q)
            levels[k + ":" + q[:3]] = q
            # bitrate ladder levels
            res = int(q[0:4]) # resolution
            br = int(q[5:10]) # bitrate
            codec = q[11:].split("_VMAF_")[0].split("_")[0]
            # mezzanine index, dict of resolutions
            ladder_json[k.rsplit("_", 1)[0]][res] = {}
            codec_key = "%s_%s" % (codec, base_directory[18:].replace("/",""))
            # use codec and test label to differentiate each codec/test's bitrate ladder and vmaf score
            ladder_json[k.rsplit("_", 1)[0]][res][codec_key] = {}
            ladder_json[k.rsplit("_", 1)[0]][res][codec_key]["bitrate"] = br
            ladder_json[k.rsplit("_", 1)[0]][res][codec_key]["vmaf"] = float(q.split("_VMAF_")[1].replace("[","").replace("]","").split(":")[0])
            ladder_json[k.rsplit("_", 1)[0]][res][codec_key]["pdiff"] = float(q.split("_VMAF_")[1].replace("[","").replace("]","").split(":")[1])
            ladder_json[k.rsplit("_", 1)[0]][res][codec_key]["psnr"] = float(q.split("_VMAF_")[1].replace("[","").replace("]","").split(":")[2])
    print("</table></tr>")
print("</table>")

good_qualities = ""
last_mezz = ""
for k, l in sorted(iter(levels.items()), reverse = True):
    mezz, br = k.split(":")
    if last_mezz != mezz:
        last_mezz = mezz
        good_qualities = "%s\\nMezzanine: %s" % (good_qualities, last_mezz)
    good_qualities = "%s\\n - %s" % (good_qualities, l)

with open(ladder_file, 'w') as f:
    f.write(json.dumps(ladder_json, sort_keys=True))

print("</body></html>\n")

