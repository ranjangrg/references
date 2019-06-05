#!/bin/bash

MAIN_PID=$$;	# PID of this script

# global variables
SERVICE_NAME="image_capture";
DEBUG=0;	# debug mode off by default
CONF_COUNT=0;	# stores how many 'conf' files are provided
IC_FORCE_JPG=0;	# forces script to save images with jpeg extension
LOG_MSG="";	# stores log messages (used by LOG_MSG)

# Variables for the service-camera
IC_SENSOR_ID=`cat /company/conf/sysid`;
IC_CAM_URL='http://ipcam/cgi-bin/guest/Video.cgi?media=JPEG&profile=1';
IC_CAM_USER='admin';
IC_CAM_PASS='';

# time gap between each capture; e.g 4 for 4 seconds, 300 for 5 minutes
IC_CAPTURE_GAP_DURATION=300;

# variables for storing directories
IC_DEST_DIR="/company/spool/";
IC_TEMP_DIR="/tmp/$SERVICE_NAME";	# will eventually store path of the 'session' temp directory;
TEMP_DIR_MAIN="$IC_TEMP_DIR";		# stores the root temp dir;
IC_TEMP_DIR_MAX_SIZE_PERCENT=80; 	# after tmp dir usage exceeds this %, clear the tmp dir of all *.img files; default: 80%
IC_PERL_FILE_PATH="/company/bin/"; 	# path to where the PERL file is; code that adds timestamp to image files
IC_PERL_FILENAME="addtimestamp.pl";

IC_LOG_DIR="/var/log/$SERVICE_NAME/"; 	# NOTE: custom log file NOT IMPLEMENTED YET

# Handling commandline options (-h, -d etc.)
while getopts ":hdc:g:p:n:j" opt; 
do
	case ${opt} in 
		h) 	# help option
			echo -e "Usage: ./image_capture.sh [OPTION]...\n Capture images from the camera using the camera's web interface";
			echo -e "at given intervals.";
			echo -e " Only short options accepted.";
			echo -e "  -h,\t this help info.";
			echo -e "  -d,\t debug mode; messages not logged to log file but to the shell instead;";
			echo -e "     \t however it still captures images and saves in 'spool' directory";
			echo -e "  -g,\t specify gap between each capture in seconds";
			echo -e "     \t note: if '-g' option is used along with '-c' option,";
			echo -e "     \t '-c' option will overwrite settings";
			echo -e "  -p,\t specify password for the ipcam";
			echo -e "  -n,\t specify sensor ID";
			echo -e "  -c,\t specify configuration file/filepath. If '-c' not used,";
			echo -e "     \t default configuration will be used.";
			echo -e "     \t note: multiple '-c' options supported. This option overrides";
			echo -e "     \t all other options: '-g', '-p' etc";
			echo -e "  -j,\t force saving images as '.jpg' instead of '.img'";
			echo -e "\n Captured files are saved as:";
			echo -e " \t'{sensor_id}_{timestamp}.img',";
			echo -e " where {sensor_id} is retrieved from '/company/conf/sysid'.";
			echo -e " And if '-j' option is used:";
			echo -e " \t'{sensor_id}_{timestamp}.jpg'";
			echo -e "";
			echo -e " Default configuration settings (if config file is not provided):";
			echo -e '\t IC_SENSOR_ID=`cat /company/conf/sysid`';	
			echo -e "\t IC_CAM_URL='http://ipcam/cgi-bin/guest/Video.cgi?media=JPEG&profile=1'";
			echo -e "\t IC_CAM_USER='admin'";
			echo -e "\t IC_CAM_PASS='<none>' \t\t\t# required";
			echo -e '\t IC_CAPTURE_GAP_DURATION=300 \t\t# about ~300 seconds';
			echo -e "\t IC_FORCE_JPG=0";
			echo -e "\t IC_DEST_DIR='/company/spool/'";
			echo -e "\t IC_TEMP_DIR='/tmp/$SERVICE_NAME'";
			echo -e "\t IC_TEMP_DIR_MAX_SIZE_PERCENT=80 \t# about ~80%";
			echo -e "\t IC_PERL_FILE_PATH='/company/bin/'";
			echo -e "\t IC_PERL_FILENAME='addtimestamp.pl'";
			echo -e "\t IC_LOG_DIR='/var/log/$SERVICE_NAME/' \t# TODO: not implemented yet";
			exit 0;
			;;
		d)	# debug mode
			echo -e "$SERVICE_NAME: running in DEBUG mode";
			DEBUG=1;
			;;
		g)	# setting gap duration from command '-g' arguments
			IC_CAPTURE_GAP_DURATION=$OPTARG;
			;;
		c)	# use config file; supports multiple 'conf' files
			CONF="$OPTARG";
			CONF_LIST[$CONF_COUNT]=$CONF;	# array to store configuration filenames
			CONF_COUNT=$(($CONF_COUNT+1));
			;;
		p)
			IC_CAM_PASS="$OPTARG";	# set ipcam password
			;;
		n)
			IC_SENSOR_ID="$OPTARG";
			;;
		j)
			IC_FORCE_JPG=1;	# set images captured as .jpg
			;;
		:)
			if [ "$OPTARG" = "g" ]; then
				# if no value/argument provided with '-g' option
				echo -e "$SERVICE_NAME: '-g' or 'gap' option requires an argument";
				echo -e "  -g, this option requires a value e.g. '-g 15' for 15 seconds gap";
			elif [ "$OPTARG" = "c" ]; then
				# if no value/argument provided with '-c' option
				echo -e "$SERVICE_NAME: '-c' or 'config' option requires an argument";
				echo -e "  -c, this option requires the configuration file path;";
			elif [ "$OPTARG" = "p" ]; then
				# if no value/argument provided with '-c' option
				echo -e "$SERVICE_NAME: '-p' or 'password' option requires an argument";
				echo -e "  -p, this option requires the password for the ipcam;";
			elif [ "$OPTARG" = "n" ]; then
				# if no value/argument provided with '-c' option
				echo -e "$SERVICE_NAME: '-n' or 'sensorID' option requires an argument";
				echo -e "  -n, this option requires the value for Sensor ID;";
			fi
				echo -e "Try '$SERVICE_NAME -h' for more information.";
			exit 1;
			;;
	esac
done	

# method to log message depending on mode (e.g. debug ...)
LOG_NOW () 
(
	if [ $DEBUG -eq 1 ]; then
		echo $LOG_MSG;	# LOG_MSG variable must be within the scope of this method
	else
		logger -t $SERVICE_NAME $LOG_MSG; 
	fi
)

# checks if a PID value is legitimate i.e. running/exists
PID_CHECK ()
(
	PID=$1;
	REPLY=0;
	if ! kill -0 $PID > /dev/null 2>&1 ;
	then
		REPLY=1;
	fi
	return $REPLY;
)

# Handle process and overwriting processes
if [ -f /var/run/$SERVICE_NAME.pid ]; then
	OLD_PID=`cat /var/run/$SERVICE_NAME.pid`;
	PID_EXISTS=PID_CHECK $OLD_PID;
	if [ $PID_EXISTS -eq 1 ]; then
		LOG_MSG="Service already running process ($OLD_PID)... aborting";
		LOG_NOW;
		exit 1;
	fi;
fi
echo $MAIN_PID > /var/run/$SERVICE_NAME.pid;

# runs the service in a subshell
RUN_SERVICE () 
(
	# setting configuration from config file
	CURRENT_CONF=$1;
	CONF_IDX=$2;
	. $CURRENT_CONF;
	
	# creating pid file for each conf session
	echo $BASHPID > /var/run/${SERVICE_NAME}.conf$CONF_IDX.pid;

	# Creating TEMP dir if it doesn't exist; GLOBAL variable scopes
	# made function just for code blocking
	CREATE_TEMP_DIR ()
	{
		if !( [ -d $IC_TEMP_DIR ] ); then
			mkdir $IC_TEMP_DIR;
			LOG_MSG="[ OK] Temp directory created: '$IC_TEMP_DIR'";
			LOG_NOW;
		fi
		# creating a temporary directory for this session; 
		# avoids conflicts with other instances of this process
		IC_TEMP_DIR="$(mktemp -d ${IC_TEMP_DIR}/session.XXX)/";
	}
	CREATE_TEMP_DIR;

	# function to clean /tmp/ dir if it is above given size (IC_TEMP_DIR_MAX_SIZE_PERCENT)
	# deletes all files with *.img extension from the temp dir
	# PLUS: final cleanup i.e. remove temp session directory in temp directory
	CLEANING_SESSION_TMP=0;
	CLEAR_TMP_DIR () 
	(
		FINAL_CLEANUP=$1; # if 1, final cleanup (deletes the tmp session directory)
		
		LOG_MSG="[CLN] Clearing tmp files at";
		if [ $FINAL_CLEANUP -eq 0 ]; then
			rm -f ${IC_TEMP_DIR}*.img;	# only delete '*.img' files from temp session dir, does not remove the directory (YET)
			LOG_MSG="$LOG_MSG '${IC_TEMP_DIR}'";
		else
			rm -rf "$IC_TEMP_DIR";	# delete temp session directory (including files inside)
			LOG_MSG="$LOG_MSG '${TEMP_DIR_MAIN}'";
		fi
		LOG_NOW;
	)

	# handles the signals sent to this subprocess (mainly via the main program)
	_child_signal_handler () 
	{
		signal=$1;
		CLEANUP_POST;
		EXIT_LOOP=1;
		CLEANING_FINAL=1;
		kill -STOP $BASHPID;	# prevent further child process from this process asap
		kill -- -$BASHPID;
		sleep 1;
	}

	# Function to clear temp dir on exit; clears all *.img file from tmp dir
	CLEANING_FINAL=0; # so that clean-up only happens once
	CLEANUP_POST ()
	(
		if [ $CLEANING_FINAL -eq 0 ]; then	
			LOG_MSG=$EXIT_MSG;
			LOG_NOW;
			CLEAR_TMP_DIR 1;
			CLEANING_FINAL=1;
		fi
	)

	# to capture interrupt signals and to handle the infinite main loop
	# known issue: on Ctrl+C, it receives multiple signals so, CLEANUP_POST may run more than once
	EXIT_LOOP=0; 
	EXIT_MSG="[END] Stopped service '$SERVICE_NAME'";
	if [ "$CURRENT_CONF" != "/dev/null" ]; then
		EXIT_MSG="$EXIT_MSG using conf: '$CURRENT_CONF'.";
	fi
	trap "_child_signal_handler TERM" TERM; 

	# Starting service; declare it in log file first
	LOG_MSG="[BEG] Starting service '$SERVICE_NAME' with pid ($$)";
	if [ "$CURRENT_CONF" == "/dev/null" ]; then
		LOG_MSG="$LOG_MSG without any 'conf' files.";
	else
		LOG_MSG="$LOG_MSG using conf: '$CURRENT_CONF' ";
	fi
	LOG_NOW;

	# Creating log dir if it doesn't exist; NOTE: custom log file NOT IMPLEMENTED YET
	#if !( [ -d $IC_LOG_DIR ] ); then
	#	mkdir $IC_LOG_DIR;
	#	LOG_MSG="[ OK] Log directory created at '$IC_LOG_DIR'";
	#	LOG_NOW;
	#fi

	# Function to add timestamp: creating a subshell
	ADD_TIMESTAMP_TO_IMAGE ()
	(
		# All files with full path as arguments
		TEMP_FILE=$1;
		TIME_NOW=$2;
		DEST_FILE=$3;
		
		if [ -f "${PERL_FILE}" ]; then
			# requires PERL libraries/packages: Imager, Time, Date .. to be installed 
			`perl -MImager -MTime::HiRes=gettimeofday -MDate::Format=time2str ${PERL_FILE} ${TEMP_FILE} "${TIME_NOW}" ${DEST_FILE} 2>&1`;		
			PERL_STATUS=$?;	# checking Perl script output status	
		else
			PERL_STATUS=3;	# 3 was chosen just because it doesn't override existing special error codes
		fi
		return $PERL_STATUS;
	)

	# handle network errors for camera
	RAISE_NETWORK_ERROR ()
	(
		ERR_CODE=$1;
		if [ $ERR_CODE -eq 1 ]; then
			LOG_MSG="[ERR] wget: Generic error (exit status '1') at URL: '$IC_CAM_URL'";
		elif [ $ERR_CODE -eq 2 ]; then
			LOG_MSG="[ERR] wget: Parsing error e.g. cmd-options like '.wgetrc' at URL: '$IC_CAM_URL'";
		elif [ $ERR_CODE -eq 3 ]; then
			LOG_MSG="[ERR] wget: File I/O error at URL: '$IC_CAM_URL'";
		elif [ $ERR_CODE -eq 4 ]; then
			LOG_MSG="[ERR] wget: Network Failure at URL: '$IC_CAM_URL'";
		elif [ $ERR_CODE -eq 5 ]; then
			LOG_MSG="[ERR] wget: SSL verification failure at URL: '$IC_CAM_URL'";	
		elif [ $ERR_CODE -eq 6 ]; then
			LOG_MSG="[ERR] wget: Authentication Failure at URL: '$IC_CAM_URL'";
		elif [ $ERR_CODE -eq 7 ]; then
			LOG_MSG="[ERR] wget: Protocol errors at URL: '$IC_CAM_URL'";		
		elif [ $ERR_CODE -eq 8 ]; then
			LOG_MSG="[ERR] wget: Server issued an error response at URL: '$IC_CAM_URL'";		
		fi
		echo $LOG_MSG;
	)

	# handle add timestamp feature errors
	GET_TIMESTAMP_ERROR_LOG ()
	(
		STATUS_CODE=$1;
		DEST_FILE=$2;
		IMG_FILENAME=$3;
		IC_DEST_DIR=$4;
		# PERL_FILE is global
		LOG_MSG="";
		if [ $STATUS_CODE -eq 0 ]; then
			LOG_MSG="[ OK] File saved at '$DEST_FILE'";
		else
			LOG_MSG="[ERR] Error saving file '$IMG_FILENAME' at '$IC_DEST_DIR'. ";
			if [ $STATUS_CODE -eq 127 ]; then
				# temporary Perl script file failed somehow
				LOG_MSG=$LOG_MSG"Couldn't run Perl script file: ${PERL_FILE}.";
			elif [ $STATUS_CODE -eq 3 ]; then
				# temporary Perl script file failed somehow
				LOG_MSG=$LOG_MSG"Couldn't find Perl script file: '${PERL_FILE}'.";						
			fi
		fi
		echo $LOG_MSG;
	)

	# handle captures that took too long; 
	# run this when image took longer than allowed to capture (i.e. went over TARGET_TIMEMARK
	# RETURNS/SENDS the new timemark based on current time
	# because we missed (gone past actually) the previous target timemark
	GET_NEW_TIMEMARK ()
	(
		END_TIME=$1; # when did the capture + add-timestamp process end
		
		CURRENT_TIMEMARK=$(($END_TIME/$IC_CAPTURE_GAP_DURATION));
		CURRENT_TIMEMARK=$(($CURRENT_TIMEMARK*$IC_CAPTURE_GAP_DURATION));
		echo $CURRENT_TIMEMARK;	# the timemark for next loop, calculated based on the END_TIME
	)

	MANAGE_TEMP_DIR_SPACE () 
	(
		# get disk use % by 'tmp' dir
		TEMP_DIR_USAGE_PERCENT=`df -h ${TEMP_DIR_MAIN} | tail -n 1 | tr -s ' ' | cut -d ' ' -f5 | tr -d '%'` 2>/dev/null;
		if [ $TEMP_DIR_USAGE_PERCENT -gt $IC_TEMP_DIR_MAX_SIZE_PERCENT ]; then
			LOG_MSG="[WAR] warning: '${TEMP_DIR_MAIN}' directory size exceeds the allowed size limit of ${IC_TEMP_DIR_MAX_SIZE_PERCENT}%";
			LOG_NOW;
			CLEAR_TMP_DIR 0;
		fi
	)

	# pre-loop setup for variables etc
	PERL_FILE="${IC_PERL_FILE_PATH}${IC_PERL_FILENAME}";
	FIRST_BEGIN_TIME=`date +%s`;
	CURRENT_TIMEMARK=$(GET_NEW_TIMEMARK $FIRST_BEGIN_TIME);

	# run forever (unless signalled)
	while [ $EXIT_LOOP -eq 0 ]
	do
		# check if 'temp' dir is taking too much space; if yes, clear tmp dir by deleteing all  *.img files
		MANAGE_TEMP_DIR_SPACE;
		
		TARGET_TIMEMARK=$(($CURRENT_TIMEMARK+$IC_CAPTURE_GAP_DURATION));
		BEGIN_TIME=`date +%s`; # normally begin time = current time mark; 
		
		# Special extension *.img used for images that will be stored in 
		# both 'video' and 'preview' column in the sensor database as *.jpg
		# this is handled by: tpbacklog.pl and receiver (SensorVideoToS3.inc.php)
		IMG_FILENAME=${IC_SENSOR_ID}_${BEGIN_TIME};
		DEST_FILE="${IC_DEST_DIR}${IMG_FILENAME}";
		TEMP_FILE="${IC_TEMP_DIR}${IMG_FILENAME}.img";
		if [ $IC_FORCE_JPG -eq 1 ]; then	# if .jpg extension is requested		
			DEST_FILE="${DEST_FILE}.jpg";
		else
			DEST_FILE="${DEST_FILE}.img";
		fi
		
		if [ $CURRENT_TIMEMARK -eq $BEGIN_TIME ]; then	
			# time is in sync with timemark; also wget-timeout period set to 2 seconds;
			wget -q --timeout=2 --user=$IC_CAM_USER --password=$IC_CAM_PASS $IC_CAM_URL -O $TEMP_FILE;
			GET_STATUS=$?;
		else
			GET_STATUS=16; # when current-time doesn't match with our timemarks i.e. not in sync, skip current capture		
		fi
		
		if [ $GET_STATUS -eq 0 ]; then
			TIME_NOW_IN_STRING=`date '+%Y-%m-%d %H:%M:%S %Z' -d @$((BEGIN_TIME))`;
			ADD_TIMESTAMP_TO_IMAGE "$TEMP_FILE" "$TIME_NOW_IN_STRING" "$DEST_FILE"; 
			EDIT_AND_SAVE_STATUS=$?; # how did the PERL code execution (for adding timestamp) go?	
			LOG_MSG=`GET_TIMESTAMP_ERROR_LOG $EDIT_AND_SAVE_STATUS "$DEST_FILE" "$IMG_FILENAME" "$IC_DEST_DIR"`;
		elif [ $GET_STATUS -lt 9 ] && [ $GET_STATUS -gt 0 ]; then # error code 1 to 8
			LOG_MSG=`RAISE_NETWORK_ERROR $GET_STATUS`;
		elif [ $GET_STATUS -eq 16 ]; then
			# when current capture is not in sync with timemarks
			TARGET_TIMEMARK_IN_STRING=`date '+%Y-%m-%d %H:%M:%S %Z' -d @$(($TARGET_TIMEMARK))`;
			LOG_MSG="[WAR] warning: Waiting for current time to sync with the nearest timemark at '$TARGET_TIMEMARK_IN_STRING'";
		else
			# so error is not caused by any of above
			LOG_MSG="[ERR] Unexpected error: Neither network nor PERL script";		
		fi
		
		LOG_NOW;
		
		# calculating how long to wait, taking 'wget' loading times into account
		END_TIME=`date +%s`; # unix-time at this moment
		WAIT_TIME=$(($TARGET_TIMEMARK-$END_TIME));

		# when we are past TARGET_TIMEMARK i.e. this capture took longer than allowed gap duration
		if [ $WAIT_TIME -lt 0 ]; then
			WAIT_TIME=0; # don't wait. just try to capture next image in coming iteration
			CURRENT_TIMEMARK=`GET_NEW_TIMEMARK $END_TIME`;	# re-calculate timemark
			LOG_MSG="[WAR] warning: current image took too long to capture (more than ${IC_CAPTURE_GAP_DURATION} secs long).";
			LOG_MSG="${LOG_MSG} Missed target timemark.";
			LOG_NOW; 
		else
			CURRENT_TIMEMARK=$(($CURRENT_TIMEMARK+$IC_CAPTURE_GAP_DURATION));
		fi

		TARGET_TIMEMARK=$(($CURRENT_TIMEMARK+$IC_CAPTURE_GAP_DURATION));

		sleep $WAIT_TIME;
	done
)

# deletes the PID file; or any file tbh
REMOVE_PID_FILE () 
(
	PID_FILE=$1;
	if [ -f $PID_FILE ]; then rm $PID_FILE; fi;
)

# kills processes with pid read from pid files
KILL_FROM_PID_FILES () 
(
	# iterate through pid files of each conf session
	for conf_pid_file in /var/run/$SERVICE_NAME.conf*.pid; do
		# first check if file exists; reads image_capture*conf.pid as filename if no match is found
		if [ -f $conf_pid_file ]; then 
			CONF_PID=`cat $conf_pid_file`;
			kill $CONF_PID;
			REMOVE_PID_FILE $conf_pid_file;	# removing pid file for this conf session
		fi;
	done

	# kill main process i.e. this program
	MAIN_PID_FILE="/var/run/$SERVICE_NAME.pid";
	if [ -f $MAIN_PID_FILE ]; then
		SERVICE_MAIN_PID=`cat $MAIN_PID_FILE`;
		kill $SERVICE_MAIN_PID; 
		REMOVE_PID_FILE $MAIN_PID_FILE;	# removing pid file for this service
	fi
)

# handle killing processes: the main process along with its child sub-processes
IS_HANDLING_EXIT=0;
_main_signal_handler() {
	signal=$1;
	if [ $IS_HANDLING_EXIT -eq 0 ]; then
		IS_HANDLING_EXIT=1;
		KILL_FROM_PID_FILES;
		sleep 1;
	fi;	
}
# separate handlers for identifying which signal is received: DEBUG purposes (can be a single line)
trap '_main_signal_handler INT' INT;
trap '_main_signal_handler EXIT' EXIT;
trap '_main_signal_handler TERM' TERM;	

# In case, no conf file is provided
if [ $CONF_COUNT -eq 0 ]; then
	RUN_SERVICE $CURRENT_CONF "/dev/null" 0 &
	wait;
else
	# Fork each 'conf' as separate sub-processes and run parallelly
	CONF_IDX=0;
	for CURRENT_CONF in ${CONF_LIST[@]}; do 
		RUN_SERVICE $CURRENT_CONF $CONF_IDX &	
		CONF_IDX=$(($CONF_IDX+1));
	done
	# important (wait command): waits for subproccesses to end (they don't normally unless interrupted)
	# or else. program will just stop after forking child processes
	wait; 
fi

exit 0;