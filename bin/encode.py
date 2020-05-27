#!/usr/bin/env python2.7

import argparse
import json
import traceback
import fcntl
from multiprocessing import Process
from os import listdir
from os import mkfifo
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
from os.path import exists
import subprocess
import sys
import time

environ["PATH"] = "%s/FFmpeg:%s" % (getcwd(), environ["PATH"])

ffmpeg_bin = "ffmpeg"
ffprobe_bin = "ffprobe"
vqmt_bin = "/usr/local/bin/vqmt"

keep_raw = False
segment = False
base_directory = ""
metrics = ""

# do not use underscores '_' in the labels
global_args = []
test_labels = [];
encoders = [];
encode_flags = [];
encode_formats = [];
audio_codecs = [];
rate_controls = [];
test_args = []
test_metrics = []
threads = 2
debug = False
use_msu = False
use_audio = False
use_experimental = False
force_framerate = False

ap = argparse.ArgumentParser()
ap.add_argument('-m', '--metrics', dest='metrics', required=False, help="Metric List. Delimited by commas: Options - psnr,vmaf,ssim")
ap.add_argument('-p', '--threads', dest='threads', required=False, help="threads to use for encoding")
ap.add_argument('-t', '--tests', dest='tests', required=True, help="Tests to run, Format - Label|FFmpegBin|RateControl|Flags|Format|arg|arg;Label|FFmpegBin|RC|FLGS|arg|arg;...")
#ap.add_argument('-a', '--encoder_args', dest='encoder_args', required=False, help="Global args for encoders - FFmpegBin|arg|arg,FFmpegBin|arg|arg")
ap.add_argument('-n', '--directory', dest='directory', required=True, help="Name of the tests base directory")
ap.add_argument('-k', '--keep_raw', dest='keep_raw', required=False, action='store_true', help="keep raw yuv avi video clips in ./videos/")
ap.add_argument('-d', '--debug', dest='debug', required=False, action='store_true', help="Debug")
ap.add_argument('-o', '--use_msu', dest='use_msu', required=False, action='store_true', help="Use MSU VQMT tool for obj metrics")
ap.add_argument('-s', '--segment', dest='segment', required=False, action='store_true', help="Use parallel encoding by splitting mezz")
ap.add_argument('-a', '--use_audio', dest='use_audio', required=False, action='store_true', help="Include Audio in encodings, default is false")
ap.add_argument('-ac', '--audio_codec', dest='audio_codec', required=False, default='aac', help="Audio codec used in encodings, default is aac")
ap.add_argument('-e', '--use_experimental', dest='use_experimental', required=False, action='store_true', help="Include experimental commands, -copyts -start_at_zero, -muxrate 0")
ap.add_argument('-r', '--force_framerate', dest='force_framerate', required=False, action='store_true', help="Force FPS by -r FPS using mezzanines value")
args = vars(ap.parse_args())

keep_raw = args['keep_raw']
base_directory = args['directory']
debug = args['debug']
if args['threads'] != None:
    threads = int(args['threads'])
#encoder_args = args['encoder_args']
use_msu = args['use_msu']
use_audio = args['use_audio']
use_experimental = args['use_experimental']
force_framerate = args['force_framerate']
segment = args['segment']
audio_codec = args['audio_codec']

mezz_dir = "%s/mezzanines" % base_directory
encode_dir = "%s/encodes" % base_directory
video_dir = "%s/videos" % base_directory
result_dir = "%s/results" % base_directory
cur_dir = getcwd()

""" Not implemented
if encoder_args != None:
    encoder_args_list = args['encoder_args'].split(',')
    for i in encoder_args_list:
        pass # TODO handle global args
"""

if args['metrics'] != None:
    metric_list = args['metrics'].split(',')
    for i in metric_list:
        test_metrics.append(i)

if args['tests'] != None:
    test_list = args['tests'].split(';')
    for i in test_list:
        if not i or i == '' or '|' not in i:
            continue # skip empty args / last ; at end
        lparts = i.split('|')
        if debug:
            print "Got: %r" % lparts
        label = lparts[0]
        encoder = lparts[1]
        rate_control = lparts[2]
        flags = lparts[3]
        encode_fmt = lparts[4]
        ac = lparts[5]
        encoder_args = lparts[6:]
        if '_' in label:
            print "Error, Test labels cannot have underscores '_' in them!"
            sys.exit(1)
        test_labels.append(label)
        encoders.append(encoder)
        rate_controls.append(rate_control)
        test_args.append(encoder_args)
        encode_flags.append(flags)
        encode_formats.append(encode_fmt)
        audio_codecs.append(ac)

print "Running test in %s directory" % base_directory

def execute(command, output_file = None):
    if debug:
        print "  # (%s) " % " ".join(command)
    process = subprocess.Popen(command, shell=False, stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                               cwd="%s" % base_directory)

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
        print "Failure getting %s metric: %s" % (test_metric, e)
        if result_fn and isfile(result_fn):
            # remove results since they are not complete
            remove(result_fn)

def encode_video(mezzanine_fn, encode_fn, rate_control, test_args,
                 global_args, encoders, pass_log_fn, threads, idx,
                 mezz_fps, format, test_force_framerate, mezz_height, mezz_width, mezz_num, mezz_den, mezz_frames):
    # cleanup any failed encodings
    if isfile(encode_fn):
        remove(encode_fn)

    if encoders == "SvtAv1EncApp" or encoders == "SvtVp9EncApp":
        mezzanine_fifo = "%s_ref.yuv" % encode_fn.replace('.', '_')
        encode_out = "%s_enc.ivf" % encode_fn.replace('.', '_')
        eprocesses = []
        p = None

        # create log and fifo in / out
        enc_log = "%s_enc.log" % encode_fn
        yuv_log = "%s_yuv.log" % encode_fn
        mp4_log = "%s_mp4.log" % encode_fn
        if isfile(mezzanine_fifo):
            remove(mezzanine_fifo)
        mkfifo(mezzanine_fifo)

        passnum = 1
        while passnum < 2 or (passnum == 2 and rate_control == 'twopass'):
            enc_log = "%s_enc_%d.log" % (encode_fn, passnum)
            # Encode (mezzanine_fifo -> encode_out)
            create_encode_cmd = [encoders, '-i', mezzanine_fifo]
            # twopass encoding
            if rate_control == "twopass":
                if passnum == 1:
                    fp_args = list(test_args)
                    for i, a in enumerate(fp_args):
                        # for av1 adjust enc-mode on first pass to 8 as recommended
                        if a == "-enc-mode":
                            fp_args[i+1] = "8"
                    create_encode_cmd = create_encode_cmd + fp_args
                    create_encode_cmd = create_encode_cmd + ['-output-stat-file', pass_log_fn]
                else:
                    create_encode_cmd = create_encode_cmd + test_args
                    create_encode_cmd = create_encode_cmd + ['-input-stat-file', pass_log_fn]
            else:
                    create_encode_cmd = create_encode_cmd + test_args

            create_encode_cmd = create_encode_cmd + ['-lp', str(threads)]
            create_encode_cmd = create_encode_cmd + ['-w', str(mezz_width), '-h', str(mezz_height),
                                                        '-fps-num', "%d" % mezz_num, '-fps-denom', "%d" % mezz_den,
                                                        '-n', str(mezz_frames)]
            create_encode_cmd = create_encode_cmd + ['-b', encode_out]
            p = Process(name="SvtEnc: %s" % mezzanine_fn, target=execute, args=(create_encode_cmd, enc_log))
            # run process in parallel
            if p != None:
                p.start()
                eprocesses.append(p)
            else:
                print "Error: Failed running Svt Encoder: %s" % mezzanine_fn
                sys.exit(1)

            # Decode YUV (mezzanine_fn -> mezzanine_fifo)
            cmd = ['ffmpeg', '-y', '-vsync', '0', '-i', mezzanine_fn, '-nostdin', '-loglevel', 'warning', '-nostats',
                     '-f', 'rawvideo', '-pix_fmt', 'yuv420p', '-an', mezzanine_fifo]
            p = Process(name="YUV: %s" % mezzanine_fn, target=execute, args=(cmd, yuv_log))
            # run each process in parallel
            if p != None:
                p.start()
                eprocesses.append(p)
            else:
                print "Error: Failed decoding to YUV: %s" % mezzanine_fn
                sys.exit(1)

            # Wait for processes to finish
            finished = False
            while not finished:
                finished = True # search if any processes are alive
                count = 0
                for i, p in enumerate(eprocesses):
                    p.join(0.1) # 1 second timeout
                    if p.is_alive(): # check if we timed out
                        count += 1
                        finished = False
                        #print "\rProcess: %s running" % p.name
            # clear processes
            eprocesses[:] = []

            # pass number
            passnum += 1

        # cleanup
        if isfile(mezzanine_fifo):
            remove(mezzanine_fifo)

        # Mux (encode_out -> encode_fn)
        cmd = ['ffmpeg', '-y', '-i', encode_out, '-nostdin', '-loglevel', 'warning', '-nostats',
                 '-f', format, '-vcodec', 'copy']
        if format == 'mp4':
            cmd.extend(['-movflags', '+faststart'])
        cmd.extend([encode_fn])
        p = Process(name="MUX: %s" % mezzanine_fn, target=execute, args=(cmd, mp4_log))
        # run process in parallel
        if p != None:
            p.start()
            eprocesses.append(p)
        else:
            print "Error: Failed muxing to MP4: %s" % mezzanine_fn
            sys.exit(1)

        # Wait for processes to finish
        finished = False
        while not finished:
            finished = True # search if any processes are alive
            count = 0
            for i, p in enumerate(eprocesses):
                p.join(0.1) # 1 second timeout
                if p.is_alive(): # check if we timed out
                    count += 1
                    finished = False
                    #print "\rProcess: %s running" % p.name

        # remove SVT encode output after muxed
        if isfile(encode_out):
            remove(encode_out)

        # Exit
        print "Done with %s Encoding" % encoders
        return

    if rate_control == "twopass":
        encode_log_1 = "%s_1.log" % pass_log_fn
        encode_log_2 = "%s_2.log" % pass_log_fn
        # pass 1
        fp_args = list(test_args)
        for i, a in enumerate(fp_args):
            # for vp9 adjust speed on first pass to 4 as recommended
            if a == "-speed":
                fp_args[i+1] = "4"
        create_encode_cmd = [encoders, '-loglevel', 'error', '-hide_banner',
            '-nostats', '-nostdin', '-i', mezzanine_fn] + global_args + fp_args + ['-pass', '1',
            '-an', '-passlogfile', pass_log_fn, '-f', format,
            '-threads', str(threads), '-y']
        # force framerate
        if test_force_framerate:
            create_encode_cmd = create_encode_cmd + ['-r', "%f" % mezz_fps]
        # Experimental args
        if use_experimental:
            create_encode_cmd = create_encode_cmd + [
                   '-copyts',
                   '-max_delay', '0',
                   '-start_at_zero']
        create_encode_cmd = create_encode_cmd + ['/dev/null']

        print "\r FirstPass Encoding [%d] %s..." % (idx, pass_log_fn)
        for output in execute(create_encode_cmd, encode_log_1):
            print "\r%s" % output
        # pass 2
        create_encode_cmd = [encoders, '-loglevel', 'warning', '-hide_banner',
            '-nostats', '-nostdin', '-i', mezzanine_fn] + global_args + test_args + ['-pass', '2',
            '-passlogfile', pass_log_fn,
            '-f', format,
            '-threads', str(threads)]
        # turn off audio if not asked for
        if not use_audio:
            create_encode_cmd = create_encode_cmd + ['-an']
        elif format == 'webm': # experimental audio vorbis / for ffmpeg
            create_encode_cmd = create_encode_cmd + ['-strict', '2']
        # force framerate
        if test_force_framerate:
            create_encode_cmd = create_encode_cmd + ['-r', "%f" % mezz_fps]
        # Experimental args
        if use_experimental:
            create_encode_cmd = create_encode_cmd + [
                   '-copyts',
                   '-max_delay', '0',
                   '-start_at_zero']
        create_encode_cmd = create_encode_cmd + [encode_fn]

        print "\r SecondPass Encoding [%d] %s..." % (idx, encode_fn)
        for output in execute(create_encode_cmd, encode_log_2):
            print output
    else:
        print "\r [%d] %s - %s encoding in one pass..." % (idx, encode_fn, encoders)
        encode_log = "%s.log" % encode_fn

        if 'ffmpeg' not in encoders:
            print "---"
            print "WARNING: Encoder %s is not supported, probably will not work!!!" % encoders
            print "---"

        ## FFmpeg Encoding
        create_encode_cmd = [encoders, '-loglevel', 'warning', '-hide_banner', '-nostats', '-nostdin',
            '-i', mezzanine_fn] + global_args + test_args + ['-threads', str(threads), '-f', format]
        # force framerate
        if test_force_framerate:
            create_encode_cmd = create_encode_cmd + ['-r', "%f" % mezz_fps]
        # Experimental args
        if use_experimental:
            create_encode_cmd = create_encode_cmd + [
                   '-copyts',
                   '-max_delay', '0',
                   '-start_at_zero']
        # turn off audio if not asked for
        if not use_audio:
            create_encode_cmd = create_encode_cmd + ['-an']
        elif format == 'webm': # experimental audio vorbis / for ffmpeg
            create_encode_cmd = create_encode_cmd + ['-strict', '2']
        create_encode_cmd = create_encode_cmd + [encode_fn]

        for output in execute(create_encode_cmd, encode_log):
            print output

def segment_cache_close(lock_file, segments, seg_dir):
    """Handle unlock of mezzanine segment cache."""
    try:
        # close lockfile
        fcntl.lockf(lock_file, fcntl.LOCK_UN)
        lock_file.close()
    except Exception, e:
        print "Failed closing lockfile: %s - %s" % (seg_dir, e)
        # something is wrong, signal the cache is rotten
        return None

    # write out the cache json index and done/complete file
    # if we have a new cache of mezz segments we just created
    # only write if segments is not None, else we are just closing the cache
    # confirm we have a .done file written, never trust .json otherwise
    if segments and not isfile("%s/segments.done" % seg_dir) and not isfile("%s/segments.json" % seg_dir):
        try:
            with open("%s/segments.json" % seg_dir, 'w') as f:
                f.write(json.dumps(segments))
            # stamp this as DONE, can't trust json otherwise
            with open("%s/segments.done" % seg_dir, 'w') as f:
                f.write("%0.4f" % time.time())
        except Exception, e:
            print "failed writing segments json to cache file: %s - %s" % (seg_dir, e)
            # nothing to do, we failed creating the cache
            return None
    # echo back segments json written out if successful
    return segments

def segment_cache_open(seg_dir):
    """
       Return a tuple containing a lockfile for segment directory cache
       and list of segments for usage if cached.  Handle creation and
       locking of mezzanine segment cache.
    """
    lock_file = "%s.lock" % (seg_dir)
    lock_file_fd = None
    segments = []
    start_time = time.time()
    # see if we have a lock already
    # attempt open, exclusive lock, wait up to 45 seconds then give up
    # if in use already.
    try:
        lock_file_fd = open(lock_file, 'w')
        # open lock file first, if fail then we give up
        if not lock_file_fd:
            raise IOError("failed opening lockfile %s for segment cache" % lock_file)
        # wait for actual file lock
        while True:
            try:
                fcntl.lockf(lock_file_fd, fcntl.LOCK_EX | fcntl.LOCK_NB)
                # Locked!
                print "got lock for %s" % lock_file
                break # got what we need
            except IOError, e:
                # non-blocking mode, check if we need to retry
                if e.errno != errno.EAGAIN:
                    # failure
                    print "IO exception getting lock for %s - %s" % (lock_file, e)
                    return (None, segments)
                # try again, sleep a second, someone has the lock
                print "%0.2f seconds Waiting for mezzanine lock %s" % ((time.time() - start_time), lock_file)
                time.sleep(1)
            except Exception, e:
                # failure
                print "Generic exception getting lock for %s - %s" % (lock_file, e)
                return (None, segments)
            # fail after waiting too long
            if time.time() - start_time >= 300:
                raise IOError("Lockfile timeout failure after %d seconds" % time.time() - start_time)
    except Exception, e:
        print "exception opening lock for %s - %s" % (lock_file, e)
        # generic failure
        return (None, segments)

    # we have a valid lock, success!
    # create tmp directory specific to duration and mezzanine path
    try:
        if not isdir("%s" % seg_dir):
            mkdir("%s" % seg_dir)
    except Exception, e:
        print "failed creating mezzanine segment cache directory: %s - %s" % (seg_dir, e)
        segment_cache_close(lock_file_fd, segments, seg_dir) # close opened cache lock
        return (None, segments)

    # check if we have a valid cached mezzanine
    if isfile("%s/%s" % (seg_dir, "segments.done")) and isfile("%s/%s" % (seg_dir, "segments.json")):
        with open("%s/%s" % (seg_dir, "segments.json"), 'r') as f:
            try:
                # get the cached mezzanine source segments
                # if this exists, cache will be used instead of segmentation
                segments = json.loads(f.read())
                # we have a valid cached mezzanine!
            except Exception, e:
                # failure, bad mezzanine segments?
                # segment them without using cache
                print "Failed retrieving past mezzanine cache, segmenting instead: %s" % e
                segment_cache_close(lock_file_fd, segments, seg_dir) # close opened cache lock
                return (None, segments)
    else:
        print "mezzanine not found in cache, segmenting into: %s" % seg_dir

    # return lock file if we succeeded
    return (lock_file_fd, segments)

def concat_video_segments(first, second, seg_dir, index, format, ext):
    """Take two video segments and combine them"""
    concat_list = "%s/merge_segments_%d.list" % (seg_dir, index)
    if not index: # generate something unique if index number not passed in
        index = str(uuid.uuid4())
    merged_segment = "%s/merged_segment_%d.%s" % (seg_dir, index, ext)
    with open(concat_list, 'w') as file:
        file.write("file '%s'\n" % first)
        file.write("file '%s'\n" % second)
    concat_cmd = [ffmpeg_bin,
               '-f', 'concat', '-safe', '0', '-i', "%s" % concat_list,
               '-f', format,
               '-codec', 'copy',
               '-copyts',
               '-max_delay', '0', '-start_at_zero',
               '-hide_banner', '-nostdin', '-loglevel', 'error', '-nostats']
    concat_cmd.extend([merged_segment])
    try:
        output = subprocess.check_output(concat_cmd)
    except Exception, e:
        print "Failed combining segment %d[%s] with the last one, %s > %s" % (index, format, second, first)
        return False
    # move new segment into place over first
    if isfile(merged_segment):
        shutil.move(merged_segment, first)
    else:
        return False
    print "Source concat segment merge output: %s" % output
    return True

def validate_segment(segment_json):
    """Confirm segment is a valid video file"""
    segment = segment_json['source']
    index = int(segment_json['index'])
    if debug:
        print "Checking segment %s with attributes %s" % (segment, segment_json)
    output = ''
    try:
        # If the first frame isn't a keyframe, this segment isn't valid.
        ffprobe_output = subprocess.check_output([ffprobe_bin,
            '-hide_banner', '-loglevel', 'error',
            segment,
            '-select_streams', 'v:%d' % 0,
            '-show_frames',
            '-show_entries', 'frame=key_frame,pict_type',
            '-read_intervals', '%+#1',
            '-of', 'json'
        ])
        first_frame = json.loads(ffprobe_output)['frames'][0]
        if first_frame['pict_type'] != 'I' or first_frame['key_frame'] != 1:
            raise ValueError("The first frame was not a keyframe. Pict type %s, key_frame %d." % (first_frame['pict_type'],
                                                first_frame['key_frame']))
    except Exception, e:
        print(traceback.format_exc())
        print "Failed validating segment [%d]%s output %s: %s" % (index, segment, output, e)
        return False
    return True

def get_segments(playlist_file, seg_dir, video_dir, format, encext):
    """Returns a list of dicts for segments from a playlist file, else an empty dict."""
    segments = []
    segnum = 0
    with open(playlist_file, 'r') as f:
        for s_line in f:
            (s_file, s_start, s_end) = s_line.split(",")

            # Fix for newer ffmpeg, it doesn't use the full path anymore in playlists
            if exists("%s/%s" % (seg_dir, s_file)):
                # mezz segment cache, stored where mezzanines are
                s_file = "%s/%s" % (seg_dir, s_file)

            # Check to see that file exists, add file if it does
            duration = float(s_end) - float(s_start)
            if (exists(s_file) and getsize(s_file) > 0):
                # create nice list of dicts for each segment we produced
                segfile = s_file
                segstart = s_start
                segstop = s_end
                encode_segment = "%s/v%d.%s" % (video_dir, segnum, encext)
                source_segment = s_file

                print "\rsegment[%d] %0.1f-%0.1f (%0.1f) %s" % (segnum+1, float(segstart), float(segstop), duration, source_segment)

                # store segment name for combination
                source_segment_dict = dict(
                     index=segnum,
                     source=source_segment,
                     encode=encode_segment,
                     start=float(segstart),
                     stop=float(segstop),
                     duration=duration,
                     result=None,
                     output='')

                # store list of segment dicts, indexed by segnum
                segments.append(source_segment_dict)
                segnum += 1
            else:
                # failed to produce file it claims exists
                print "Failure to produce a segment in m3u8 list: %s" % s_file
                return {}

    # Confirm we got a list of segments
    if len(segments) <= 0:
        print "Failed to segment mezzanine, 0 segments output."
        return {}

    # check if we didn't segment, if not then just return
    if len(segments) == 1:
        return segments

    # Validate segments, fail if one doesn't work
    last_segment = {}
    number_of_segments = len(segments)
    combined_count = 0
    new_index = 0
    fixed_segments= []
    for s in segments:
        # give up if more than 2 fail
        if (combined_count == 1):
            print "Too many failed segments %d, giving up on combining" % combined_count
            return {}
        index = int(s['index']) # we skip bad segments and rewrite the index for them
        segments[index]['index'] = index # renumber index
        if debug:
            print "Segment Validate [%d]: last [%s], current [%s]" % (index, last_segment, s)
        if not validate_segment(s):
            if not last_segment or index == 0:
                return {} # on first segment, can't repair: failed
            print "Segment Invalid [%d]: [%s]!" % (index, s)
            # attempt to repair segment
            fixed_segments_index = len(fixed_segments) - 1 # get current fixed segments position
            concat_video_segments(last_segment['source'], s['source'], seg_dir, index, format, encext)
            # fix up metadata on the original segments list
            last_index = int(last_segment['index'])
            fixed_segments[fixed_segments_index]['stop'] = s['stop'] # set last segment to this ones stop
            fixed_segments[fixed_segments_index]['duration'] = last_segment['stop'] - last_segment['start'] # calculate new segment duration
            print "Removed segment %d, combined with last: %s -> %s" % (index, s['source'], last_segment['source'])
            # confirm the reparied segment is ok
            if not validate_segment(fixed_segments[fixed_segments_index]):
                # this failed, give up, really rare edge case
                print "Combined Segment Invalid [%d]: [%s], old: [%s]!" % (fixed_segments_index, fixed_segments[fixed_segments_index], s)
                return {}
            # extra increment index offset for entry skip
            combined_count += 1
        else:
            last_segment.clear()
            last_segment = s # keep track of last good segment
            # create a new list with the valid segments and combined ones
            fixed_segments.append({})
            fixed_segments[new_index] = segments[index].copy()
            new_index += 1

    if new_index != len(segments):
        print "Merged %d segments that were invalid for the mezzanine, changed from %d to %d entries" % (combined_count,
            new_index, len(segments))

    # fixed up list of merged segments and time information stored as dicts
    return fixed_segments

def segment_source(mezzanine_fn, vcodec, video_framerate, seg_dir, video_dir, video_duration, processes, cache, ext, format, encext, framerate):
    """Split Source Video into parts, returns list of source segments."""
    # calc source segment duration
    source_segment_duration = max(1, int((video_duration/1000.0) / max(1.0, float(processes)))+1)
    if debug:
        print "Source video duration: %f Segment duration: %f" % (video_duration, source_segment_duration)
    # setup and lock cache directory for mezzanine segments
    segment_lock = None
    segments = []
    if cache:
        (segment_lock, segments) = segment_cache_open(seg_dir)
        # if we have a valid cache of segments, use it, unlock and return
        if segment_lock and len(segments) > 0:
            # make sure we have the number of segments requested
            if len(segments) > 0 and len(segments) >= processes:
                segments = segment_cache_close(segment_lock, segments, seg_dir)
                # update encode output for this encode
                for s in segments:
                    s['encode'] = "%s/v%d.%s" % (video_dir, s['index'], encext)
                return segments # cached segments

    playlist_file = "%s/v.csv" % seg_dir
    segment_pattern = "%s/m%%d.%s" % (seg_dir, ext)
    cmd = [ffmpeg_bin]
    # if mpeg we need to generate pts ts for missing start timestamps
    # https://trac.ffmpeg.org/ticket/1979
    if vcodec == 'mpeg4' or vcodec == 'xvid':
        cmd.extend(['-fflags', '+genpts'])
    cmd.extend(['-i', mezzanine_fn, '-codec', 'copy',
               '-map', '0:v',
               '-an', '-dn', '-sn',
               '-f', 'ssegment',
               '-segment_list_size', '0',
               '-segment_time_delta', '%s' % (1/(2*video_framerate))])
    cmd.extend(['-segment_time', '%s' % source_segment_duration])
    cmd.extend(['-reset_timestamps', '0'])
    cmd.extend(['-segment_list', playlist_file, '-segment_list_type', 'csv',])
    cmd.extend(['-hide_banner', '-nostdin', '-loglevel', 'error', '-nostats'])
    cmd.extend(['-individual_header_trailer', '1'])
    cmd.extend(['-write_header_trailer', '1'])
    cmd.extend(['-segment_format', format])
    if use_experimental and format == 'mpeg':
        cmd.extend(['-preload', '0'])
        cmd.extend(['-max_delay', '0'])
        cmd.extend(['-start_at_zero'])

    cmd.extend([segment_pattern])
    try:
        if debug:
            print "Running Segmentation cmd: %s" % ' '.join(cmd)
        output = subprocess.check_output(cmd)
        if debug:
            print "Source segment output: %s" % output
        # Extract filenames of segments from playlist and time offsets
        segments = get_segments(playlist_file, seg_dir, video_dir, format, encext)
    except Exception, e:
        print "Source segmentation failed: %s" % e
        return []
    finally:
        # unlock cache segments if we got a lock, even if we failed to segment
        if segment_lock:
            # if fails, we don't use the segments, bad cache?
            segment_cache_close(segment_lock, segments, seg_dir)

    # confirm source exists, setup destination for encoding files
    for segment in segments:
        # check for source segment existing, if not then a bad cache
        if 'source' not in segment or not isfile(segment['source']):
            # hit a bad segment, it is all bad, rewrite cache if possible, or give up on segmenting
            # break this loop, we just created a fresh segment so should be fine
            print "Bad segment list, invalid segment found: %r" % segment
            return []

    return segments

def prepare_encode(source_segments, audio_file, tmp_dir, video_file, mezz_fps, encext, ac):
    """
    Take list of segments, audio file, and format, concat/mux/format.

    Create list of files to concatenate with the ffmpeg,
    concat stream muxer, rewrites timestamps, fixes a/v sync.
    """
    # create a concat muxer file list of segments to combine
    concat_list = "%s/mezz_segments" % tmp_dir
    total_duration = 0.0
    with open(concat_list, 'w') as file:
        for segment in source_segments:
            if debug:
                print "adding encode to source segments: %r" % segment
            encode = segment['encode']
            file.write("file '%s/%s'\n" % (getcwd(), encode))
            file.write("duration %f\n" % segment['duration'])
            total_duration += segment['duration']

    # Combine encoded segements back into one single video file
    analyzeduration = min(2147480000, int((total_duration / 2.0) * 1000000.0))
    concat_cmd = [ffmpeg_bin , '-analyzeduration', str(analyzeduration),
               '-f', 'concat', '-safe', '0', '-y']
    concat_cmd = concat_cmd + ['-i', "%s" % concat_list]

    if use_audio:
        audio_c = audio_codec
        if ac != "":
            audio_c = ac
        concat_cmd = concat_cmd + ['-i', audio_file, '-map', '1:a', '-acodec', audio_c]

    concat_cmd = concat_cmd + [
               '-map', '0:v',
               '-f', encext,
               '-vcodec', 'copy',
               '-hide_banner', '-nostdin', '-loglevel', 'error', '-nostats']
    # force framerate
    if force_framerate:
        concat_cmd = concat_cmd + ['-r', "%f" % mezz_fps]
    # Experimental args
    if use_experimental:
        concat_cmd = concat_cmd + [
               '-copyts',
               '-max_delay', '0',
               '-start_at_zero']
    if encext == 'mp4':
        concat_cmd.extend(['-movflags', '+faststart'])
    concat_cmd.extend([video_file])
    if debug:
        print "Running recombine: %s" % ' '.join(concat_cmd)
    output = subprocess.check_output(concat_cmd)
    print "Muxed A/V output: %s" % output


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
    test_letter1 = 'A'
    test_letter2 = 'A'
    test_letter3 = 'A'
    test_letter = test_letter1
    test_label_idx = 0
    processes = []
    decoded_encodes = []

    mezzanine_fn = "%s/%s/%s" % (cur_dir, mezz_dir, m)

    # get mezzanine duration
    params = "--Inform=General;%Duration%,%OverallBitRate%"
    cmd = ['mediainfo', params, mezzanine_fn]
    print " - extracting metadata from format..."
    stdout = subprocess.check_output(cmd)
    data_string = "".join([line for line in stdout if
                    ((ord(line) >= 32 and ord(line) < 128) or ord(line) == 10 or ord(line) == 13)]).strip()
    mezz_duration = float(data_string.split(',')[0])

    params = "--Inform=Video;%CodecID%,%FrameRate%,%Height%,%Width%,%Format%,%FrameRate_Num%,%FrameRate_Den%,%FrameRate_Maximum%"
    cmd = ['mediainfo', params, mezzanine_fn]
    print " - extracting metadata from video..."
    stdout = subprocess.check_output(cmd)
    data_string = "".join([line for line in stdout if
                    ((ord(line) >= 32 and ord(line) < 128) or ord(line) == 10 or ord(line) == 13)]).strip()
    vcodec = "%s" % data_string.split(',')[0].lower()
    mezz_fps = float(data_string.split(',')[1])
    mezz_fps_max = data_string.split(',')[7]
    if mezz_fps_max != "":
        mezz_fps = float(mezz_fps_max)
    mezz_height = int(data_string.split(',')[2])
    mezz_width = int(data_string.split(',')[3])
    mezz_format = "%s" % data_string.split(',')[4].lower()
    mezz_num = 0.0
    mezz_den = 0.0
    # not all formats have these values
    try:
        mezz_num = float(data_string.split(',')[5])
        mezz_den = float(data_string.split(',')[6])
    except Exception, e:
        pass
    mezz_frames = int(mezz_fps * (mezz_duration / 1000)+1)

    print "mezzanine:\n\tcodec: %s\n\tformat: %s\n\tframerate: %f\n\tframesize: %s\n\tduration: %0.2f\n\tframes: %d" % (vcodec,
                                                                    mezz_format, mezz_fps, "%dx%d" % (mezz_width, mezz_height),
                                                                    mezz_duration, mezz_frames)

    for test_label in test_labels:
        rate_control = rate_controls[test_label_idx]
        # Flags:
        ## - S: Segment Encode
        ## - F: Force mezzanine FPS
        flags = encode_flags[test_label_idx]
        encode_format = encode_formats[test_label_idx]
        ac = audio_codecs[test_label_idx]

        # Filenames 
        encode_fn = "%s/%s/%s_%s_%s.%s" % (cur_dir, encode_dir, m.split('.')[0], test_label, test_letter, encode_format)
        encode_data_fn = "%s/%s/%s_%s_%s.%s_data.json" % (cur_dir, encode_dir, m.split('.')[0], test_label, test_letter, encode_format)
        pass_log_fn = "%s/%s/%s_%s_%s.%s_pass.log" % (cur_dir, encode_dir, m.split('.')[0], test_label, test_letter, encode_format)
        mezzanine_video_fn = "%s/%s/%s.avi" % (cur_dir, video_dir, m.split('.')[0])
        encode_video_fn = "%s/%s/%s_%s_%s.avi" % (cur_dir, video_dir, m.split('.')[0], test_label, test_letter)
        result_base = "%s/%s/%s_%s_%s" % (cur_dir, result_dir, m.split('.')[0], test_label, test_letter)
        speed_result = "%s/%s/%s_%s_%s_speed.json" % (cur_dir, result_dir, m.split('.')[0], test_label, test_letter)
        print "\n%s:" % mezzanine_fn
        print " %s" % encode_fn

        # Encode mezzanine
        if not isfile(encode_fn) or getsize(encode_fn) <= 0:
            processes = []
            try:
                start_time = time.time()
                segment_encode = False
                test_force_framerate = False
                if 'S' in flags:
                    segment_encode = True
                if 'F' in flags:
                    test_force_framerate = True
                if force_framerate:
                    test_force_framerate = True
                mezzanine_segments = []
                encode_segments = []
                source_segments = []
                p = None
                enc_dir = None
                encext = "%s" % encode_format # final encode extension: TODO make option for encode per line
                # split mezzanine here
                if segment or segment_encode:
                    print " - splitting mezzanine into segments for parallel encoding..."
                    seg_dir = "%s/%s_%d" % (video_dir, m.split('.')[0], threads)
                    enc_dir = "%s/%s_%d" % (video_dir, "%s_%s_%s" % (m.split('.')[0], test_label, test_letter), threads)
                    if not isdir(enc_dir):
                        mkdir(enc_dir)
                    ext = m.split('.')[1]
                    format = "mp4" # segmented mezz split format
                    segencfmt = "%s" % encode_format # format for encode segments
                    segencext = "%s" % encode_format # extension for combining segments
                    if mezz_format == "prores":
                        format = "mov"
                        ext = "mov"
                    elif vcodec == "avc1" or ext == "mp4" or mezz_format == "mpeg-4 visual":
                        format = "mp4"
                        ext = "mp4"
                    elif mezz_format == "mpeg video":
                        format = "mpeg"
                        ext = "mpg"
                    elif ext == "mov":
                        format = "mov"
                    elif ext == "wmv":
                        format = "asf"
                    elif ext == "avi":
                        format = "mp4"
                        ext = "mp4"
                    else:
                        ext = "mp4" # unknown format / codec
                        format = "mp4"

                    print "Segmenting format: %s extension: %s segment_format: %s segment_extension: %s" % (format, ext, segencfmt, segencext)

                    source_segments = segment_source(mezzanine_fn, vcodec, mezz_fps, seg_dir, enc_dir, mezz_duration, threads, True, ext, format, segencext, mezz_fps)
                    #
                    # run multiple processes for each segment
                    if len(source_segments) > 0:
                        for idx, s in enumerate(source_segments):
                            mezzanine_segment = "%s/%s" % (cur_dir, s['source'])
                            mezzanine_segments.append(mezzanine_segment)
                            encode_segment = "%s/%s" % (cur_dir, s['encode'])
                            encode_segments.append(encode_segment)
                            pass_log_fn = "%s/%s/%s_%s_%s_pass.log" % (cur_dir,
                                            encode_dir, "%s_%d" % (m.split('.')[0], s['index']), test_label, test_letter)
                            # calc threads per segment depending on how many segments we got back
                            seg_threads = max(2,min(threads, int((float(threads) * 2.0) / float(len(source_segments)))))
                            if debug:
                                print "Segment: threads: %d mezzanine: %s encode: %s passlog: %s" % (seg_threads,
                                                                                                 mezzanine_segment, encode_segment, pass_log_fn)
                            encode_segments.append(encode_segment)
                            p = Process(name=encode_segment, target=encode_video, args=(mezzanine_segment, encode_segment,
                                            rate_control, test_args[test_label_idx], global_args,
                                            encoders[test_label_idx], pass_log_fn, seg_threads, (idx+1),
                                            mezz_fps, segencfmt, test_force_framerate, mezz_height, mezz_width, mezz_num, mezz_den, mezz_frames))
                            # run each encode in parallel
                            if p != None:
                                p.start()
                                processes.append(p)
                            else:
                                print "Error: didn't get any mezzanine segments when splitting %s" % mezzanine_fn
                                sys.exit(1)
                else:
                    p = Process(name=encode_fn, target=encode_video, args=(mezzanine_fn, encode_fn,
                                    rate_control, test_args[test_label_idx], global_args,
                                    encoders[test_label_idx], pass_log_fn, threads, 1,
                                    mezz_fps, encext, test_force_framerate, mezz_height, mezz_width, mezz_num, mezz_den, mezz_frames))
                    # run encode
                    if p != None:
                        p.start()
                        processes.append(p)

                # wait for encode processes to finish
                finished = False
                print "---"
                print "Starting encoding processes..."
                start_wait_time = time.time()
                while not finished:
                    running_procs = []
                    finished = True # search if any processes are alive
                    count = 0
                    for i, p in enumerate(processes):
                        p.join(0.1) # 1 second timeout
                        fsize = 0 # encode filesize
                        if isfile(p.name):
                            fsize = getsize(p.name)
                        if p.is_alive(): # check if we timed out
                            count += 1
                            finished = False
                            running_procs.append("%s:%d" % (p.name.split('/')[-1].split('.')[0], fsize))

                    sys.stdout.flush()
                    sys.stdout.write("\r%s[%d/%d]%s" % (test_label, count, time.time() - start_wait_time, '|'.join(running_procs)))
                    sys.stdout.flush()

                # mux together encoding segments if needed
                if segment or segment_encode:
                    prepare_encode(source_segments, mezzanine_fn, enc_dir, encode_fn, mezz_fps, encext, ac)

                # mux segmented parallel encoding parts into one
                if len(encode_segments) > 0:
                    for es in encode_segments:
                        if isfile(es):
                            if debug:
                                print "Deleting Encode segment: %s" % es
                            remove(es)

                # clean up mezzanine segments
                if not segment and not segment_encode and len(mezzanine_segments) > 0:
                    for ms in mezzanine_segments:
                        mezzanine_segment = "%s/%s" % (mezz_dir, ms)
                        if isfile(mezzanine_segment):
                            if debug:
                                print "Deleting mezzanine segment: %s" % mezzanine_segment
                            remove(mezzanine_segment)

                end_time = time.time()
                with open(speed_result, "w") as f:
                    f.write("{\"file\":\"%s\",\"speed\":\"%d\"}" % (encode_fn, int(end_time - start_time)))
            except Exception, e:
                print(traceback.format_exc())
                print "Failure Encoding: %s" % e
                for p in processes:
                    if p.is_alive():
                        p.terminate() # kill processes so they don't hang around
                    if isfile(p.name):
                        remove(p.name) # remove files
        else:
            print " Encode exists"

        #if not isfile(encode_data_fn) or getsize(encode_data_fn) <=0:
        # create data file in json with encode stats
        # get filesize, bitrate, framerate, duration, vcodec
        filesize = getsize(encode_fn)
        params = "--Inform=General;%Duration%,%OverallBitRate%"
        cmd = ['mediainfo', params, encode_fn]
        print " - extracting metadata from format..."
        stdout = subprocess.check_output(cmd)
        data_string = "".join([line for line in stdout if
                        ((ord(line) >= 32 and ord(line) < 128) or ord(line) == 10 or ord(line) == 13)]).strip()
        duration = -1
        print "reading media stats: %s" % data_string
        if data_string != ',':
            duration = "%0.3f" % float(data_string.split(',')[0])
        if duration < 1:
            print "Error reading media stats: '%s' doesn't contain duration,bitrate bad encoding!!!" % data_string
            # increment test label
            test_label_idx += 1
            continue
        bitrate = "%s" % data_string.split(',')[1].strip()
        data = {}
        data['video'] = {}
        data['video']['filesize'] = filesize
        data['video']['duration'] = float(duration) / 1000.0
        data['video']['vbitrate'] = int(bitrate) / 1000
        params = "--Inform=Video;%FrameRate%,%Height%,%Width%"
        cmd = ['mediainfo', params, encode_fn]
        print " - extracting metadata from video..."
        stdout = subprocess.check_output(cmd)
        data_string = "".join([line for line in stdout if
                        ((ord(line) >= 32 and ord(line) < 128) or ord(line) == 10 or ord(line) == 13)]).strip()
        framerate = float(data_string.split(',')[0])
        height = int(data_string.split(',')[1])
        width = int(data_string.split(',')[2])
        data['video']['framerate'] = framerate
        data['video']['height'] = height
        data['video']['width'] = width
        with open(encode_data_fn, "w") as f:
            f.write(json.dumps(data))

        # decode raw yuv versions of encodes if we are using MSU tools
        if use_msu or keep_raw:
            print " %s" % mezzanine_video_fn
            if not isfile(mezzanine_video_fn) or getsize(mezzanine_video_fn) <= 0:
                # Decode mezzanie to raw YUV AVI format for VQMT and Subj PQMT
                create_mezzanine_video_cmd = [ffmpeg_bin, '-loglevel', 'warning', '-hide_banner', '-y', '-nostats', '-nostdin', '-i', mezzanine_fn,
                    '-f', 'avi', '-vcodec', 'rawvideo', '-pix_fmt', 'yuv420p', '-dn', '-sn', '-an', mezzanine_video_fn]
                try:
                    print " - decoding mezzanine to raw YUV..."
                    for output in execute(create_mezzanine_video_cmd):
                        print output
                except Exception, e:
                    print "Failure Decoding: %s" % e
            else:
                print " Mezzanine AVI exists"
            print " %s" % encode_video_fn
            if not isfile(encode_video_fn) or getsize(encode_video_fn) <= 0:
                # Decode encode to raw YUV AVI format for VQMT and Subj PQMT
                create_encode_video_cmd = [ffmpeg_bin, '-loglevel', 'warning', '-hide_banner', '-y', '-nostats', '-nostdin', '-i', encode_fn,
                    '-f', 'avi', '-vcodec', 'rawvideo', '-pix_fmt', 'yuv420p', '-dn', '-sn', '-an', encode_video_fn]
                try:
                    print " - decoding encoding to raw YUV..."
                    for output in execute(create_encode_video_cmd):
                        print output
                except Exception, e:
                    print "Failure Decoding: %s" % e
            else:
                print " Encode AVI exists"

        # VQMT metrics results
        print " %s" % result_base
        p = None
        mdata_files = []
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
                    print " - calculating the %s score for encoding..." % test_metric
                    p = Process(target=get_results, args=(test_metric, result_fn, encode_video_fn, create_result_cmd,))
                    # run each metric in parallel
                    if p != None:
                        p.start()
                        processes.append(p)
                        decoded_encodes.append(encode_video_fn)
        elif len(test_metrics) > 0:
            result_fn_json = "%s_%s.json" % (result_base, 'phqm')
            result_fn = "%s_%s.data" % (result_base, 'phqm')
            result_fn_stdout = "%s_%s.stdout" % (result_base, 'phqm')
            print " - %s" % result_fn
            # get psnr and perceptual difference metrics
            if not isfile(result_fn) or getsize(result_fn) <= 0:
                create_result_cmd = [ffmpeg_bin, '-loglevel', 'warning', '-i', encode_fn,
                    '-i', mezzanine_fn, '-nostats', '-nostdin', '-threads', str(threads),
                    '-filter_complex', '[0:v]scale=h=%d:w=%d:flags=bicubic[enc]; [1:v]scale=h=%d:w=%d:flags=bicubic[ref]; [enc][ref]phqm=stats_file=%s' % (height, width, height, width,
                                                                                                                                        result_fn), '-an', '-y', '-f', 'null', '/dev/null']
                print " - calculating the %s score for encoding..." % "phqm"
                p = Process(target=get_results, args=('phqm', result_fn_stdout, encode_fn, create_result_cmd,))
                # run each metric in parallel
                if p != None:
                    p.start()
                    processes.append(p)
            if not isfile(result_fn_json):
                mdata_files.append("%s:%s:%s" % (result_fn, result_fn_stdout, 'phqm'))
            # only do vmaf if ssim or it has been requested
            if 'ssim' in test_metrics or 'vmaf' in test_metrics:
                result_fn_json = "%s_%s.json" % (result_base, 'vmaf')
                result_fn = "%s_%s.data" % (result_base, 'vmaf')
                result_fn_stdout = "%s_%s.stdout" % (result_base, 'vmaf')
                print " - %s" % result_fn
                if not isfile(result_fn) or getsize(result_fn) <= 0:
                    create_result_cmd = [ffmpeg_bin, '-loglevel', 'warning', '-i', encode_fn, '-i', mezzanine_fn,
                        '-nostats', '-nostdin', '-threads', str(threads),
                        '-filter_complex', '[0:v]scale=h=%d:w=%d:flags=bicubic[enc]; [1:v]scale=h=%d:w=%d:flags=bicubic[ref]; [enc][ref]libvmaf=psnr=1:ms_ssim=1:log_fmt=json:log_path=%s' % (height, width, height, width, result_fn), '-an', '-y', '-f', 'null', '/dev/null']
                    print " - calculating the %s score for encoding..." % "vmaf"
                    p = Process(target=get_results, args=('vmaf', result_fn_stdout, encode_fn, create_result_cmd,))
                    if p != None:
                        p.start()
                        processes.append(p)
                if not isfile(result_fn_json):
                    mdata_files.append("%s:%s:%s" % (result_fn, result_fn_stdout, 'vmaf'))

        if test_letter2 == 'Z':
            test_letter = test_letter1 + test_letter2 + test_letter3
            test_letter3 = chr(ord(test_letter3) + 1).upper()
        elif test_letter1 == 'Z':
            test_letter = test_letter1 + test_letter2
            test_letter2 = chr(ord(test_letter2) + 1).upper()
        else:
            test_letter1 = chr(ord(test_letter1) + 1).upper()
            test_letter = test_letter1
        test_label_idx += 1
        # Encode processing end

        # wait for metrics processes to finish
        for p in processes:
            p.join()

        # parse any non-json data metric files from ffmpeg
        for d in mdata_files:
            files = d.split(':')
            result_fn = files[0]
            result_fn_stdout = files[1]
            file_type = files[2]
            if file_type == "vmaf":
                result_fn_vmaf = "%s_%s.json" % (result_base, 'vmaf')
                result_fn_msssim = "%s_%s.json" % (result_base, 'msssim')
                result_fn_psnr = "%s_%s.json" % (result_base, 'psnr')
                psnr_data = {"avg":[]}
                msssim_data = {"avg":[]}
                vmaf_data = {"avg":[]}
                """
                Exec FPS: 2.300914
                VMAF score = 54.891245
                PSNR score = 31.984645
                MS-SSIM score = 0.918881
                """
                dline = []
                with open(result_fn_stdout, "r") as f:
                    data = f.readlines()
                for i, line in enumerate(data):
                    if "VMAF score = " in line:
                        dline.append(line)
                        vmaf_avg = float(line.split('=')[1])
                        vmaf_data["avg"].append(vmaf_avg)
                    elif "PSNR score = " in line:
                        dline.append(line)
                        psnr_avg = float(line.split('=')[1])
                        psnr_data["avg"].append(psnr_avg)
                    elif "MS-SSIM score = " in line:
                        dline.append(line)
                        msssim_avg = float(line.split('=')[1])
                        msssim_data["avg"].append(msssim_avg)
                    if len(dline) >= 3:
                        break

                if len(msssim_data["avg"]) > 0:
                    with open(result_fn_msssim, "w") as f:
                        f.write(json.dumps(msssim_data))
                if len(vmaf_data["avg"]) > 0:
                    with open(result_fn_vmaf, "w") as f:
                        f.write(json.dumps(vmaf_data))
                if len(psnr_data["avg"]) > 0:
                    with open(result_fn_psnr, "w") as f:
                        f.write(json.dumps(psnr_data))
            elif file_type == "phqm":
                result_fn_phqm = "%s_%s.json" % (result_base, 'phqm')
                result_fn_pfhd = "%s_%s.json" % (result_base, 'pfhd')
                phqm_data = {"avg":[]}
                pfhd_data = {"avg":[]}
                """
                [Parsed_img_hash_0 @ 0x7fb73b609ac0] PHQM average:1.933974 PSNR y:29.030691
                    u:36.543688 v:36.685639 average:30.428417 min:20.791527 max:49.168489
                """
                dline = None
                with open(result_fn_stdout, "r") as f:
                    data = f.readlines()
                for i, line in enumerate(data):
                    if "PHQM average:" in line:
                        dline = line
                        break
                if dline is not None:
                    parts = dline.split(' ')
                    phqm_avg = float(parts[4].split(':')[1])
                    pfhd_avg = float(parts[7].split(':')[1])
                    if debug:
                        print "PHQM AVG: %0.3f" % phqm_avg
                        print "PFHD AVG: %0.3f" % pfhd_avg
                    phqm_data["avg"].append(phqm_avg)
                    pfhd_data["avg"].append(pfhd_avg)

                if len(phqm_data["avg"]) > 0:
                    with open(result_fn_phqm, "w") as f:
                        f.write(json.dumps(phqm_data))

                if len(pfhd_data["avg"]) > 0:
                    with open(result_fn_pfhd, "w") as f:
                        f.write(json.dumps(pfhd_data))

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
