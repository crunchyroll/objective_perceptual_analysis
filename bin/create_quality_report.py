#!/usr/bin/env python2.7

import argparse
from os import getcwd
from os import listdir
from os import environ
import subprocess

VIVICT_URLBASE = "http://svt.github.io/vivict/"
STORAGE_URLBASE = "http://your-http-storage.com/"
REFERENCE_LABEL = "08000X264H264"
CURRENT_DIR = getcwd()
RESULTS_SCRIPT = "results.py"
environ["PATH"] = "bin/:%s" % (environ["PATH"])


ap = argparse.ArgumentParser()
ap.add_argument('-n', '--directory', dest='directory', required=True, help="Name of the tests base directory")
ap.add_argument('-v', '--vivict_urlbase', dest='vivict_urlbase', default=VIVICT_URLBASE, required=False, help="Web server running vivict player")
ap.add_argument('-s', '--storage_urlbase', dest='storage_urlbase', default=STORAGE_URLBASE, required=False, help="Web server with videos accessible")
args = vars(ap.parse_args())

base_directory = args['directory']
vivict_urlbase = args['vivict_urlbase']
storage_urlbase = args['storage_urlbase']

#%s?leftVideoUrl=%s&rightVideoUrl=%s&hideSourceSelector=1&hideHelp=1&position=10&duration=10

results = subprocess.check_output(['results.py', '-n', base_directory])
encode = None
label = None
stats = None
metrics = None
scenes = []
encode_list = {}
for r in results.splitlines():
    if r[1] != ' ':
        encode = r.replace(':', '')
        print "Encode: %s" % encode
        encode_list[encode] = {}
    elif "Encode [" in r:
            label = r
            print "Label: %s" % label
            encode_list[encode]["label"] = label.replace("]", "").replace("[", "")
    elif "Stats: " in r:
        stats = r
        print "Stats: %s" % stats
        encode_list[encode]["stats"] = stats
    elif "Metrics: " in r:
        metrics = r
        print "Metrics: %s" % metrics
        encode_list[encode]["metrics"] = metrics
    else:
        scenes.append(r)
        print "Scene: %s" % r
        if 'scenes' not in encode_list[encode]:
            encode_list[encode]["scenes"] = []
        encode_list[encode]["scenes"].append(r)

print "Encode List: %r" % encode_list

encode_dir = "%s/encodes" % base_directory
encodes = [f for f in listdir(encode_dir)]
encodes = encodes
reference_encode = None
for e in sorted(encodes):
    if e[0] == '.' or e.split(".")[1] != "mp4":
            # skip .dotfiles
            continue
    if REFERENCE_LABEL in e:
        reference_encode = e

for e in sorted(encodes):
    if e[0] == '.' or e.split(".")[1] != "mp4":
            # skip .dotfiles
            continue
    print "Encode: %s Reference: %s" % (e, reference_encode)

