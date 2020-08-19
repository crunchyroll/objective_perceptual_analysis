#!/usr/bin/env python2.7

import argparse
import json
from os import path


ap = argparse.ArgumentParser()
ap.add_argument('-n', '--directories', dest='directories', required=True, help="Comma delimited list of test directories to merge")

args = vars(ap.parse_args())

base_directories = args['directories']

directories = base_directories.split(",")

ladders = {}
for d in directories:
    ladder_file = "%s/ladders.json" % d
    label = d[6:].replace("/","")
    #print "Label: %s" % label
    if path.isfile(ladder_file):
        ladder_json = None
        with open(ladder_file, 'r') as lf:
            ladder_json = json.loads(lf.read())
        # mezzanines
        for m, v in sorted(ladder_json.iteritems()):
            if m not in ladders:
                ladders[m] = {}
            # resolutions
            for r, d in sorted(v.iteritems()):
                if r not in ladders[m]:
                    ladders[m][r] = {}
                # codecs
                for c, i in sorted(d.iteritems()):
                    if c not in ladders[m][r]:
                        # codec information
                        # - bitrate, vmaf score
                        ladders[m][r][c] = i
                        ladders[m][r][c]["mezzanine"] = "%s_%s_%s" % (m, c, r)
                        ladders[m][r][c]["codec"] = "%s_%s" % (c, r)
                        ladders[m][r][c]["resolution"] = "%s" % (r)
    else:
        print "Error, missing %s file" % ladder_file

print json.dumps(ladders, indent = True, sort_keys = True)
