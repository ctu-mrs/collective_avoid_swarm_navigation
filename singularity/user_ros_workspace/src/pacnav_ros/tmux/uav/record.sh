#!/bin/bash

path="/home/\$(optenv USER mrs)/bag_files/latest/"

# By default, we record everything.
# Except for this list of EXCLUDED topics:
exclude=(

# IN GENERAL, DON'T RECORD CAMERAS
#
# If you want to record cameras, create a copy of this script
# and place it at your tmux session.
#
# Please, seek an advice of a senior researcher of MRS about
# what can be recorded. Recording too much data can lead to
# ROS communication hiccups, which can lead to eland, failsafe
# or just a CRASH.

# EXCLUDE INTEGRATOR
'(.*)integrator(.*)'

# EXCLUDE NORMALIZER
'(.*)normalizer(.*)'

# mobius
'(.*)mobius/image_raw'
# Every topic containing "theora"
'(.*)mobius/image_raw/theora(.*)'
# Every topic containing "h264"
'(.*)mobius/image_raw/h264(.*)'

'(.*)rs_d435/(.*)depth(.*)'

'(.*)rs_d435/color/image_raw'
'(.*)rs_d435/color/image_raw/theora(.*)'
# '(.*)rs_d435/color/image_raw/compressed(.*)'
'(.*)rs_d435/color/image_raw/compressedDepth(.*)'

'(.*)rs_d435/color/image_rect_raw(.*)'
# openvino pose debug
'(.*)openvino_ros/pose_debug'
'(.*)pose_filtering(.*)'
'(.*)intel_pose(.*)'

)

# file's header
filename=`mktemp`
echo "<launch>" > "$filename"
echo "<arg name=\"UAV_NAME\" default=\"\$(env UAV_NAME)\" />" >> "$filename"
echo "<group ns=\"\$(arg UAV_NAME)\">" >> "$filename"

echo -n "<node pkg=\"mrs_uav_general\" type=\"mrs_record\" name=\"mrs_rosbag_record\" args=\"-o $path -a" >> "$filename"

# if there is anything to exclude
if [ "${#exclude[*]}" -gt 0 ]; then

  echo -n " -x " >> "$filename"

  # list all the string and separate the with |
  for ((i=0; i < ${#exclude[*]}; i++));
  do
    echo -n "${exclude[$i]}" >> "$filename"
    if [ "$i" -lt "$( expr ${#exclude[*]} - 1)" ]; then
      echo -n "|" >> "$filename"
    fi
  done

fi

echo "\">" >> "$filename"

echo "<remap from=\"~status_msg_out\" to=\"mrs_uav_status/display_string\" />" >> "$filename"
echo "<remap from=\"~data_rate_out\" to=\"~data_rate_MB_per_s\" />" >> "$filename"

# file's footer
echo "</node>" >> "$filename"
echo "</group>" >> "$filename"
echo "</launch>" >> "$filename"

cat $filename
roslaunch $filename