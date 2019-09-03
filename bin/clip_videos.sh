#!/bin/sh

# Read a list of mezzanines with in-clip point and duration in seconds to clip
# Below is an example where we clip 300 seconds in for 10 seconds time total duration
#
##File video.txt example:
#
# Mezzanine.avi 300 10
#
#

video_list="$1"

mezzanine_dir="mezzanines"

ffmpeg="./bin/ffmpeg"

cat $video_list | while read l; do
    mezzanine=$(echo $l | awk '{print $1}')
    filebase=$(basename "${mezzanine%.*}")
    start_seconds=$(echo $l | awk '{print $2}')
    total_seconds=$(echo $l | awk '{print $3}')
    clipped_mezz="${filebase}-${start_seconds}_${total_seconds}.avi"
    echo $ffmpeg -hide_banner -y -nostdin -ss $start_seconds -t $total_seconds -i $mezzanine -vcodec copy $mezzanine_dir/$clipped_mezz
done
