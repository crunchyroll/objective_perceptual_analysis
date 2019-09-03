#!/usr/bin/python2.7

import json
from multiprocessing import Process
from os import listdir
from os.path import isfile, join
from os.path import basename
from os.path import splitext
from os import environ
from os import getcwd
from os import remove
from os import mkdir
from os.path import isfile
from os.path import isdir
from os.path import getsize
import subprocess
import sys
import time

mezz_dir = "mezzanines"
encode_dir = "encodes"
video_dir = "videos"
result_dir = "results"
cur_dir = getcwd()

delete_avi = False

# get list of mezzanines
mezzanines = [f for f in listdir(mezz_dir)]

# label tests from encode.sh for easier human reading
# do not use underscores '_' in the labels
test_labels = [
            'b8000-H264-prod',
            'b5000-vp9-s2',
            'b5000-vp9-s1',
            'b4000-vp9-s2',
            'b4000-vp9-s1']
global_args = []
test_args = [
          ['-b:v', '8000', '-vcodec', 'libx264'],
          ['-b:v', '5000', '-speed', '2', '-vcodec', 'libvpx-9'],
          ['-b:v', '5000', '-speed', '1', '-vcodec', 'libvpx-9'],
          ['-b:v', '4000', '-speed', '2', '-vcodec', 'libvpx-9'],
          ['-b:v', '4000', '-speed', '1', '-vcodec', 'libvpx-9']]
test_metrics = ['vmaf', 'psnr', 'msssim']
threads = 12

debug = True

ffmpeg_bin = "./bin/ffmpeg"
vqmt_bin = "/usr/local/bin/vqmt"

def execute(command, output_file = None):
    if debug:
        print "  # (%s) " % " ".join(command)
    process = subprocess.Popen(command, shell=False, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)

    # Poll process for new output until finished
    while True:
        nextline = process.stdout.readline()
        if nextline == '' and process.poll() is not None:
            break
        sys.stdout.write(nextline)
        sys.stdout.flush()
        if output_file:
            # write results if output file specified
            with open(output_file, "a+") as f:
                f.write(nextline)

    output = process.communicate()[0]
    exitCode = process.returncode

    if (exitCode == 0):
        return output
    else:
        raise subprocess.ProcessException(command, exitCode, output)

def get_results(test_metric, result_fn, encode_video_fn, create_result_cmd):
    try:
        for output in execute(create_result_cmd, result_fn):
            # collect output for file storage
            print "%s" % output
    except Exception, e:
        print "Failure getting VQMT %s metric: %s" % (test_metric, e)
        if isfile(result_fn):
            # remove results since they are not complete
            remove(result_fn)

# create directories needed
if not isdir(mezz_dir):
    mkdir(mezz_dir)
if not isdir(encode_dir):
    mkdir(encode_dir)
if not isdir(video_dir):
    mkdir(video_dir)
if not isdir(result_dir):
    mkdir(result_dir)

for m in mezzanines:
    if m[0] == ".":
        continue
    test_letter = 'A'
    test_label_idx = 0
    processes = []
    decoded_encodes = []
    for test_label in test_labels:
        mezzanine_fn = "%s/%s/%s" % (cur_dir, mezz_dir, m)
        encode_fn = "%s/%s/%s_%s_%s.mp4" % (cur_dir, encode_dir, m.split('.')[0], test_label, test_letter)
        mezzanine_video_fn = "%s/%s/%s.avi" % (cur_dir, video_dir, m.split('.')[0])
        encode_video_fn = "%s/%s/%s_%s_%s.avi" % (cur_dir, video_dir, m.split('.')[0], test_label, test_letter)
        result_base = "%s/%s/%s_%s_%s" % (cur_dir, result_dir, m.split('.')[0], test_label, test_letter)
        speed_result = "%s/%s/%s_%s_%s_speed.json" % (cur_dir, result_dir, m.split('.')[0], test_label, test_letter)
        print "\n%s:" % mezzanine_fn
        print " %s" % encode_fn
        # Encode mezzanine
        if not isfile(encode_fn) or getsize(encode_fn) <= 0:
            create_encode_cmd = [ffmpeg_bin,
                '-i', mezzanine_fn] + global_args + test_args[test_label_idx]
                + ['--output_file', encode_fn,
                '--threads', str(threads)]
            try:
                start_time = time.time()
                for output in execute(create_encode_cmd):
                    print output
                end_time = time.time()
                with open(speed_result, "w") as f:
                    f.write("{\"file\":\"%s\",\"speed\":\"%d\"}" % (encode_fn, int(end_time - start_time)))
            except Exception, e:
                print "Failure Encoding: %s" % e
        else:
            print " Encode exists"
        print " %s" % mezzanine_video_fn
        if not isfile(mezzanine_video_fn) or getsize(mezzanine_video_fn) <= 0:
            # Decode mezzanie to raw YUV AVI format for VQMT and Subj PQMT
            create_mezzanine_video_cmd = [ffmpeg_bin, '-hide_banner', '-y', '-nostdin', '-i', mezzanine_fn,
                '-f', 'avi', '-vcodec', 'rawvideo', '-pix_fmt', 'yuv420p', '-dn', '-sn', '-an', mezzanine_video_fn]
            try:
                for output in execute(create_mezzanine_video_cmd):
                    print output
            except Exception, e:
                print "Failure Decoding: %s" % e
        else:
            print " Mezzanine AVI exists"
        print " %s" % encode_video_fn
        if not isfile(encode_video_fn) or getsize(encode_video_fn) <= 0:
            # Decode encode to raw YUV AVI format for VQMT and Subj PQMT
            create_encode_video_cmd = [ffmpeg_bin, '-hide_banner', '-y', '-nostdin', '-i', encode_fn,
                '-f', 'avi', '-vcodec', 'rawvideo', '-pix_fmt', 'yuv420p', '-dn', '-sn', '-an', encode_video_fn]
            try:
                for output in execute(create_encode_video_cmd):
                    print output
            except Exception, e:
                print "Failure Decoding: %s" % e
        else:
            print " Encode AVI exists"
        # VQMT metrics results
        print " %s" % result_base
        for test_metric in test_metrics:
            result_fn = "%s_%s.json" % (result_base, test_metric)
            print " - %s" % result_fn
            color_component = "YYUV"
            if not isfile(result_fn) or getsize(result_fn) <= 0:
                create_result_cmd = [vqmt_bin, '-orig', mezzanine_video_fn, '-in', encode_video_fn,
                    '-metr', test_metric, color_component, '-resize', 'cubic', 'to', 'orig', '-threads', str(threads), '-terminal', '-json']
                # run each metric in parallel
                p = Process(target=get_results, args=(test_metric, result_fn, encode_video_fn, create_result_cmd,))
                p.start()
                processes.append(p)
                decoded_encodes.append(encode_video_fn)

        test_letter = chr(ord(test_letter) + 1).upper()
        test_label_idx += 1
        # Encode processing end

    # wait for metrics processes to finish
    for p in processes:
        p.join()

    # clean up AVI files, they are large. unless requested to keep them for subj tests
    if delete_avi:
        for en in decoded_encodes:
            if isfile(en):
                remove(en)

    # Mezzanine processing end
    # clean up AVI files, mezzanine after finished with encode stats
    if delete_avi:
        if isfile(mezzanine_video_fn):
            remove(mezzanine_video_fn)
