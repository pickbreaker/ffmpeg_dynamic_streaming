#!/bin/bash

VIDEO_IN=${PWD}/in.mp4	#Infile
HLS_TIME=4		#Segment duration in s
FPS=25			#Frames per second
GOP_SIZE=100		#Keyframe interval
CRF_P=21		#Quality
PRESET_P=veryslow	#Compression preset
V_SIZE_1=960x540	#List of resolutions
V_SIZE_2=416x234
V_SIZE_3=640x360
V_SIZE_4=768x432
V_SIZE_5=1280x720
V_SIZE_6=1920x1080
A_BITRATE=128k		#Audio Bitrate
A_CHANNELS=2		#Number of Audio Channels
TUNE=film		#Type of input to tune the params to

while [ -n "$1" ]; do 

	case "$1" in

	--hls_time|-t)
			HLS_TIME="$2"
			shift
			;;

	--input|-i)
			VIDEO_IN="$2"
			shift
			;;
	-fps|-f)
			FPS="$2"
			shift
			;;

	--film)
			TUNE=film
			;;

	--animation)
			TUNE=animation
			;;

	--fastdecode)
			TUNE=fastdecode
			;;

	--zerolatency)
			TUNE=zerolatency
			;;

	--stillimage)
			TUNE=stillimage
			;;

	--preservegrain)
			TUNE=grain
			;;

	--stereo)
			A_CHANNELS=2
			;;
	--mono)
			A_CHANNELS=1
			;;

	*)
			echo "Unknown option $1"
			;;
			esac
			shift
done

ffmpeg -loglevel debug -i "$VIDEO_IN" -y \
    -preset $PRESET_P -keyint_min $GOP_SIZE -g $GOP_SIZE -sc_threshold 0 -tune $TUNE -r $FPS -crf $CRF_P -c:v libx264 -pix_fmt yuv420p\
    -c:a aac -b:a $A_BITRATE -ac $A_CHANNELS -ar 44100\
    -map v:0 -s:0 $V_SIZE_1 -b:v:0 2M -maxrate:0 2.14M -bufsize:0 3.5M \
    -map v:0 -s:1 $V_SIZE_2 -b:v:1 145k -maxrate:1 155k -bufsize:1 220k \
    -map v:0 -s:2 $V_SIZE_3 -b:v:2 365k -maxrate:2 390k -bufsize:2 640k \
    -map v:0 -s:3 $V_SIZE_4 -b:v:3 730k -maxrate:3 781k -bufsize:3 1278k \
    -map v:0 -s:4 $V_SIZE_4 -b:v:4 1.1M -maxrate:4 1.17M -bufsize:4 2M \
    -map v:0 -s:5 $V_SIZE_5 -b:v:5 3M -maxrate:5 3.21M -bufsize:5 5.5M \
    -map v:0 -s:6 $V_SIZE_5 -b:v:6 4.5M -maxrate:6 4.8M -bufsize:6 8M \
    -map v:0 -s:7 $V_SIZE_6 -b:v:7 6M -maxrate:7 6.42M -bufsize:7 11M \
    -map v:0 -s:8 $V_SIZE_6 -b:v:8 7.8M -maxrate:8 8.3M -bufsize:8 14M \
    -map 0:a \
    -init_seg_name init\$RepresentationID\$.\$ext\$ -media_seg_name chunk\$RepresentationID\$-\$Number%05d\$.\$ext\$ \
    -use_template 1 -use_timeline 1  \
    -seg_duration 4 -adaptation_sets "id=0,streams=v id=1,streams=a" \
    -f dash Dash/dash.mpd
