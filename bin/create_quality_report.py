#!/usr/bin/env python2.7

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
args = vars(ap.parse_args())

base_directory = args['directory']
vivict_urlbase = args['vivict_urlbase']
storage_urlbase = args['storage_urlbase']
reference_label = args['reference_label']
debug = args['debug']
minimum_quality = float(args['quality'])
exclude_quality = args['exclude']

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
            print "Encode: %s" % encode
        encode_list[encode] = {}
    elif "Encode [" in r:
            label = r[11:].replace("]", "").replace("[", "").replace(":", "")
            if debug:
                print "Label: %s" % label
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
            print "Stats: %s" % (stats)
        encode_list[encode]["stats"] = stats
    elif "Metrics: " in r:
        metrics = r.replace("   Metrics: ", "")
        if debug:
            print "Metrics: %s" % (metrics)
        encode_list[encode]["metrics"] = metrics
    else:
        if debug:
            print "Scene: %s" % r
        if "scenes" not in encode_list[encode]:
            encode_list[encode]["scenes"] = []
        encode_list[encode]["scenes"].append(r[10:])

if debug:
    print "Encode List: %s" % json.dumps(encode_list, indent=4)

quality_good = []

print "<html><title>Encode Quality Comparison %s</title>" % base_directory
print "<head><style>table, th, td, h1, caption { border: 3px solid #ff6600; padding: 5px; border-collapse: collapse; vertical-align: top; color: white; }\nbody { color: white; background-color: black; }\na:link, a:visited { color: yellow; }</style></head>"
print "<body>"
print "<table><caption style=\"background-color: #000000; \"><h1><a style=\"color: #eeeeee; \" href=\"%s/%s/stats.json\">Encode Quality Comparsion (%s)</a></h1>" % (storage_urlbase, base_directory, base_directory)
print "<a href=\"%s/%s/stats.jpg\"><img src=\"%s/%s/stats.jpg\" width=640 height=380></a></caption>" % (storage_urlbase, base_directory, storage_urlbase, base_directory)
print "<tr><th style=\"background-color:#ff6600;color:#000000\">Encode</th><th style=\"background-color:#ff6600;color:#000000\">scenes</th></tr>"
for encode, data in sorted(encode_list.iteritems()):
    metadata_file = "%s/encodes/%s.mp4_data.json" % (base_directory, encode)
    metadata = "None"
    if path.isfile(metadata_file):
        with open(metadata_file, 'r') as mf:
            metadata = mf.read()
    metadata_json = json.loads(metadata)
    metrics_json = json.loads(data["metrics"])
    total_vmaf_score = float(metrics_json["vmaf"])
    data["vmaf"] = total_vmaf_score
    # check if this matches our minimum quality expectations
    if exclude_quality and total_vmaf_score < minimum_quality:
        continue
    if debug:
        print "Encode: %s" % encode
        print "Mezzanine: %s" % data["reference"]
        # {bitrate: 778, filesize: 10649765, duration: 109.48}
        print "Stats: %s" % data["stats"]
        #   {speed: 416.00, pfhd: 1.97 hamm: 1.66 phqm: 66.79 vmaf: 96.08, ssim: 1.00, psnr: 47.33}
        print "Metrics: %s" % data["metrics"]

    print "<tr>"
    if "reference" not in data:
        data["reference"] = "Not-Finished-Yet"

    is_good = True
    if "scenes" not in data:
        data["scenes"] = []
    else:
        for scene in data["scenes"]:
            vmaf_score = float(scene.split(" ")[5].split(":")[1])
            if vmaf_score < minimum_quality:
                is_good = False
    if total_vmaf_score < minimum_quality:
        is_good = False
    bcolor = "red"
    fcolor = "black"
    if is_good:
        bcolor = "green"
        fcolor = "black"
    print "<td><table><tr style=\"vertical-align:top\">"
    print "<td style=\"background-color:%s;color:%s\"><strong>Encode: (%s)</strong></td>" % (bcolor, fcolor, data["label"])
    print "<td><a href=%s>%s</a></td></tr><tr>" % ("%s?leftVideoUrl=%s&rightVideoUrl=%s&hideSourceSelector=1&hideHelp=1&score=0&quality=" % (vivict_urlbase, "%s/%s/%s" % (storage_urlbase, "%s/encodes" % base_directory, data["reference"]), "%s/%s/%s" % (storage_urlbase, "%s/encodes" % base_directory, "%s.mp4" % encode)), encode)
    print "<td><strong>Reference: (%s)</strong></td><td>%s</td></tr><tr>" % (reference_label, data["reference"])
    # {"video": {"framerate": 23.976, "vbitrate": 102, "height": 240, "width": 427, "filesize": 1397598, "duration": 109.485}}
    print "<td><strong>Mediainfo: </strong></td><td>%s</td></tr><tr>" % (json.dumps(json.loads(metadata), indent=4).replace("\n", "<br>").replace(" ", "&nbsp;"))
    print "<td><strong>Stats:</strong></td><td>%s</td></tr><tr><td><strong>Metrics:</strong></td><td>%s</td></tr></table></td><td><table>" % (json.dumps(json.loads(data["stats"]), indent=4).replace("\n", "<br>").replace(" ", "&nbsp;"), json.dumps(json.loads(data["metrics"]), indent=4).replace("\n", "<br>").replace(" ", "&nbsp;"))
    vmaf_good = True
    for scene in data["scenes"]:
        start_frame, end_frame = scene.split(" ")[0].split("-")
        framerate = float(metadata_json["video"]["framerate"])
        position = int(float(start_frame) / framerate)
        duration = int(float(int(end_frame) - int(start_frame)) / framerate)
        vmaf_score = float(scene.split(" ")[5].split(":")[1])

        # %s?leftVideoUrl=%s&rightVideoUrl=%s&hideSourceSelector=1&hideHelp=1&position=10&duration=10
        if debug:
            print "Scene: %s" % scene
        url = "%s?leftVideoUrl=%s&rightVideoUrl=%s&hideSourceSelector=1&hideHelp=1&position=%d&duration=%d&score=0&quality=" % (vivict_urlbase,
                                                                                                           "%s/%s/%s" % (storage_urlbase, "%s/encodes" % base_directory, data["reference"]),
                                                                                                           "%s/%s/%s" % (storage_urlbase, "%s/encodes" % base_directory, "%s.mp4" % encode),
                                                                                                           position, duration)
        if debug:
            print "Url: %s" % url
        bcolor = "green"
        fcolor = "black"
        lcolor = "blue"
        if vmaf_score < (minimum_quality - 10):
            bcolor = "black"
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
        print "<tr><td style=\"background-color:%s;color:%s\"><strong>%d-%ds [%0.2f%%]:</strong> <a style=\"color:%s;visited:%s\" href=%s>%s</a></td></tr>" % (bcolor,
                                                                                                                                 fcolor, position, position+duration,
                                                                                                                                 vmaf_score, lcolor, lcolor, url, ": ".join(scene.split(" ")[1:8]))
    print "</table></td></tr>"
    if vmaf_good and data["vmaf"] >= minimum_quality:
        quality_good.append(data["label"])

print "</table>"

print "<br>"
print "<table>"
print "<caption><h1>Encodes that pass Quality levels</h1></caption>"
levels = {}
for q in quality_good:
    if q[:3] not in levels and reference_label not in q:
        print "<tr><td><h2>%s<h2></td></tr>" % q
        levels[q[:3]] = q
print "</table>"

good_qualities = ""
for k, l in levels.iteritems():
    good_qualities = "%s\\n - %s" % (good_qualities, l)
print "<script>alert(\"Qualities that pass:\\n%s\")</script>" % good_qualities

print "</body></html>\n"

