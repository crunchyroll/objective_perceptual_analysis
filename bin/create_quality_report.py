#!/usr/bin/env python2.7

import argparse
from os import getcwd
from os import listdir
from os import environ
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
ap.add_argument('-d', '--debug', dest='debug', required=False, action='store_true', help="Debug")
args = vars(ap.parse_args())

base_directory = args['directory']
vivict_urlbase = args['vivict_urlbase']
storage_urlbase = args['storage_urlbase']
debug = args['debug']

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
                if REFERENCE_LABEL in e and encode[0:len(encode)-(len(label))] in e:
                    reference_encode = e
                    encode_list[encode]["reference"] = e
                    encode_list[encode]["encode_file"] = encode_file

    elif "Stats: " in r:
        stats = r
        if debug:
            print "Stats: %s" % stats
        encode_list[encode]["stats"] = stats.replace("    Stats: ", "");
    elif "Metrics: " in r:
        metrics = r
        if debug:
            print "Metrics: %s" % metrics
        encode_list[encode]["metrics"] = metrics.replace("   Metrics: ", "")
    else:
        if debug:
            print "Scene: %s" % r
        if "scenes" not in encode_list[encode]:
            encode_list[encode]["scenes"] = []
        encode_list[encode]["scenes"].append(r[10:])

if debug:
    print "Encode List: %s" % json.dumps(encode_list, indent=4)

for encode, data in sorted(encode_list.iteritems()):
    print "Encode: %s" % encode
    print "Mezzanine: %s" % data["reference"]
    print "Stats: %s" % data["stats"]
    print "Metrics: %s" % data["metrics"]

    for scene in data["scenes"]:
        start_frame, end_frame = scene.split(" ")[0].split("-")
        framerate = 29.976
        position = int(float(start_frame) / framerate)
        duration = int(float(int(end_frame) - int(start_frame)) / framerate)
        # %s?leftVideoUrl=%s&rightVideoUrl=%s&hideSourceSelector=1&hideHelp=1&position=10&duration=10
        print "Scene: %s" % scene
        url = "%s?leftVideoUrl=%s&rightVideoUrl=%s&hideSourceSelector=1&hideHelp=1&position=%d&duration=%d" % (vivict_urlbase,
                                                                                                           "%s/%s/%s" % (storage_urlbase, "%s/encodes" % base_directory, "%s.mp4" % encode),
                                                                                                           "%s/%s/%s" % (storage_urlbase, "%s/encodes" % base_directory, data["reference"]),
                                                                                                           position, duration)
        print "Url: %s" % url

    print "\n"

