#!/usr/bin/python2.7

import argparse
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

ffmpeg_bin = "./FFmpeg/ffmpeg"
vqmt_bin = "/usr/local/bin/vqmt"

keep_raw = False
base_directory = ""
metrics = ""

# do not use underscores '_' in the labels
global_args = []
test_labels = [];
encoders = [];
test_args = []
test_metrics = []
threads = 2
debug = True
use_msu = False

ap = argparse.ArgumentParser()
ap.add_argument('-m', '--metrics', dest='metrics', required=False, help="Metric List. Delimited by commas: Options - psnr,vmaf,ssim")
ap.add_argument('-p', '--threads', dest='threads', required=False, help="threads to use for encoding")
ap.add_argument('-t', '--tests', dest='tests', required=True, help="Tests to run, Format - Label|EncoderBin|arg|arg,Label|EncoderBin|arg|arg,...")
ap.add_argument('-a', '--encoder_args', dest='encoder_args', required=False, help="Global args for encoders - EncoderBin|arg|arg,EncoderBin|arg|arg")
ap.add_argument('-n', '--directory', dest='directory', required=True, help="Name of the tests base directory")
ap.add_argument('-k', '--keep_raw', dest='keep_raw', required=False, action='store_true', help="keep raw yuv avi video clips in ./videos/")
ap.add_argument('-d', '--debug', dest='debug', required=False, action='store_true', help="Debug")
ap.add_argument('-o', '--use_msu', dest='use_msu', required=False, action='store_true', help="Use MSU VQMT tool for obj metrics")
args = vars(ap.parse_args())

keep_raw = args['keep_raw']
base_directory = args['directory']
debug = args['debug']
if args['threads'] != None:
    threads = int(args['threads'])
encoder_args = args['encoder_args']
use_msu = args['use_msu']

mezz_dir = "%s/mezzanines" % base_directory
encode_dir = "%s/encodes" % base_directory
video_dir = "%s/videos" % base_directory
result_dir = "%s/results" % base_directory
cur_dir = getcwd()

print "encoder_args='%s'" % encoder_args
if encoder_args != None:
    encoder_args_list = args['encoder_args'].split(',')
    for i in encoder_args_list:
        pass # TODO parse and add to array of encoders w/global args

if args['metrics'] != None:
    metric_list = args['metrics'].split(',')
    for i in metric_list:
        test_metrics.append(i)

if args['tests'] != None:
    test_list = args['tests'].split(',')
    for i in test_list:
        lparts = i.split('|')
        label = lparts[0]
        encoder = lparts[1]
        encoder_args = lparts[2:]
        if '_' in label:
            print "Error, Test labels cannot have underscores '_' in them!"
            sys.exit(1)
        test_labels.append(label)
        encoders.append(encoder)
        test_args.append(encoder_args)

print "Running test in %s directory" % base_directory

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
        raise Exception(command, exitCode, output)

def get_results(test_metric, result_fn, encode_video_fn, create_result_cmd):
    try:
        for output in execute(create_result_cmd, result_fn):
            # collect output for file storage
            print "%s" % output
    except Exception, e:
        print "Failure getting VQMT %s metric: %s" % (test_metric, e)
        if result_fn and isfile(result_fn):
            # remove results since they are not complete
            remove(result_fn)

# create directories needed
if not isdir(base_directory):
    mkdir(base_directory)
if not isdir(mezz_dir):
    mkdir(mezz_dir)
if not isdir(encode_dir):
    mkdir(encode_dir)
if not isdir(video_dir):
    mkdir(video_dir)
if not isdir(result_dir):
    mkdir(result_dir)

# get list of mezzanines
mezzanines = [f for f in listdir(mezz_dir)]

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
        encode_data_fn = "%s/%s/%s_%s_%s.mp4_data.json" % (cur_dir, encode_dir, m.split('.')[0], test_label, test_letter)
        mezzanine_video_fn = "%s/%s/%s.avi" % (cur_dir, video_dir, m.split('.')[0])
        encode_video_fn = "%s/%s/%s_%s_%s.avi" % (cur_dir, video_dir, m.split('.')[0], test_label, test_letter)
        result_base = "%s/%s/%s_%s_%s" % (cur_dir, result_dir, m.split('.')[0], test_label, test_letter)
        speed_result = "%s/%s/%s_%s_%s_speed.json" % (cur_dir, result_dir, m.split('.')[0], test_label, test_letter)
        print "\n%s:" % mezzanine_fn
        print " %s" % encode_fn
        # Encode mezzanine
        if not isfile(encode_fn) or getsize(encode_fn) <= 0:
            create_encode_cmd = [ffmpeg_bin,
                '-i', mezzanine_fn] + global_args + test_args[test_label_idx] + [encode_fn,
                '-threads', str(threads)]
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

        # get encode information
        if not isfile(encode_data_fn) or getsize(encode_data_fn) <=0:
            # create data file in json with encode stats
            # get filesize, bitrate, framerate, duration, vcodec
            filesize = getsize(encode_fn)
            params = "--Inform=General;%Duration%,%OverallBitRate%"
            cmd = ['mediainfo', params, encode_fn]
            stdout = subprocess.check_output(cmd)
            data_string = "".join([line for line in stdout if
                            ((ord(line) >= 32 and ord(line) < 128) or ord(line) == 10 or ord(line) == 13)]).strip()
            duration = "%0.3f" % float(data_string.split(',')[0])
            bitrate = "%s" % data_string.split(',')[1].strip()
            data = {}
            data['video'] = {}
            data['video']['filesize'] = filesize
            data['video']['duration'] = float(duration) / 1000.0
            data['video']['vbitrate'] = int(bitrate) / 1000
            with open(encode_data_fn, "w") as f:
                f.write(json.dumps(data))

        # get metrics
        if use_msu:
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
        p = None
        if use_msu:
            for test_metric in test_metrics:
                result_fn = "%s_%s.json" % (result_base, test_metric)
                print " - %s" % result_fn
                color_component = "YYUV"
                if not isfile(result_fn) or getsize(result_fn) <= 0:
                    create_result_cmd = [vqmt_bin, '-orig', mezzanine_video_fn, '-in', encode_video_fn,
                        '-metr', test_metric, color_component,
                        #'-resize', 'cubic', 'to', 'orig',
                        '-threads', str(threads), '-terminal', '-json']
                    p = Process(target=get_results, args=(test_metric, result_fn, encode_video_fn, create_result_cmd,))
                    # run each metric in parallel
                    if p != None:
                        p.start()
                        processes.append(p)
                        decoded_encodes.append(encode_video_fn)
        elif len(test_metrics) > 0:
            result_fn = "%s_%s.data" % (result_base, 'phqm')
            result_fn_stdout = "%s_%s.stdout" % (result_base, 'phqm')
            print " - %s" % result_fn
            # get psnr and perceptual difference metrics
            if not isfile(result_fn) or getsize(result_fn) <= 0:
                create_result_cmd = [ffmpeg_bin, '-i', encode_fn, '-i', mezzanine_fn, '-nostats', '-nostdin', '-threads', str(threads),
                    '-filter_complex', '[0:v][1:v]img_hash=stats_file=%s' % result_fn, '-f', 'null', '-']
                p = Process(target=get_results, args=('vmaf', result_fn_stdout, encode_fn, create_result_cmd,))
                # run each metric in parallel
                if p != None:
                    p.start()
                    processes.append(p)
            # only do vmaf if ssim or it has been requested
            if 'ssim' in test_metrics or 'vmaf' in test_metrics:
                result_fn = "%s_%s.data" % (result_base, 'vmaf')
                result_fn_stdout = "%s_%s.stdout" % (result_base, 'vmaf')
                print " - %s" % result_fn
                if not isfile(result_fn) or getsize(result_fn) <= 0:
                    create_result_cmd = [ffmpeg_bin, '-i', encode_fn, '-i', mezzanine_fn, '-nostats', '-nostdin', '-threads', str(threads),
                        '-filter_complex', '[0:v][1:v]libvmaf=psnr=1:ms_ssim=1:log_fmt=json:log_path=%s' % result_fn, '-f', 'null', '-']
                    p = Process(target=get_results, args=('vmaf', result_fn_stdout, encode_fn, create_result_cmd,))
                    if p != None:
                        p.start()
                        processes.append(p)

        test_letter = chr(ord(test_letter) + 1).upper()
        test_label_idx += 1
        # Encode processing end

    # wait for metrics processes to finish
    for p in processes:
        p.join()

    # clean up AVI files, they are large. unless requested to keep them for subj tests
    if keep_raw:
        for en in decoded_encodes:
            if isfile(en):
                remove(en)

    # Mezzanine processing end
    # clean up AVI files, mezzanine after finished with encode stats
    if keep_raw:
        if isfile(mezzanine_video_fn):
            remove(mezzanine_video_fn)
