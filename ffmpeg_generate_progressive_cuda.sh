#!/bin/bash

VIDEO_IN=${PWD}/in.mp4	#Infile
FPS=25			#Frames per second
GOP_SIZE=100		#Keyframe interval
CRF_P=21		#Quality
PRESET_P=veryslow	#Compression preset
V_SIZE=960x540		#List of resolutions
A_BITRATE=128k		#Audio Bitrate
A_CHANNELS=2		#Number of Audio Channels
TUNE=film		#Type of input to tune the params to

while [ -n "$1" ]; do 

	case "$1" in

	--input|-i)
			VIDEO_IN="$2"
			shift
			;;
	--fps|-f)
			FPS="$2"
			shift
			;;
	--res|-r)
			V_SIZE="$2"
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

ffmpeg -loglevel debug -hwaccel cuda -i "$VIDEO_IN" -y \
    -keyint_min $GOP_SIZE -g $GOP_SIZE -sc_threshold 0 -tune $TUNE -r $FPS -crf $CRF_P -c:v h264_nvenc -pix_fmt yuv420p -movflags +faststart\
    -c:a aac -b:a $A_BITRATE -ac $A_CHANNELS -ar 44100\
    -s $V_SIZE -b:v 1.8M -maxrate:0 2.14M -bufsize:0 3.5M \
    fallback-video-$V_SIZE.mp4
