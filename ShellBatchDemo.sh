#!/bin/sh

# global variables
SERVICE_NAME="image_capture";

SENSOR_ID=`cat /xxxxxxxxx/conf/sysid`;
#SENSOR_ID='9999_t'
CAM_URL='http://ipcam/cgi-bin/guest/Video.cgi?media=JPEG&profile=1';
CAM_USER='admin';
CAM_PASS='';	# for security purposes

# time gap between each capture; e.g 4 for 4 seconds, 300 for 5 minutes
CAPTURE_GAP_DURATION=300;

DEST_DIR="/xxxxxxxxx/spool/";
TEMP_DIR="/tmp/$SERVICE_NAME";		# will eventually store path of the 'session' temp directory;
TEMP_DIR_MAIN="$TEMP_DIR"		# stores the root temp dir;
TEMP_DIR_SIZE_LIMIT=36700160; 		# after tmp dir reaches this size, clear the tmp dir of all *.img files; default: 35MB
PERL_FILE_PATH="/xxxxxxxxx/bin/"; 	# path to where the PERL file is; code that adds timestamp to image files
PERL_FILENAME="addtimestamp.pl";

LOG_DIR="/var/log/$SERVICE_NAME/"; 	# NOTE: custom log file NOT IMPLEMENTED YET

LOG_MSG="";

DEBUG=0;

# Handling commandline options (-h, -d etc.)
while getopts ":hdc:g:" opt; 
do
	case ${opt} in 
		h) 	# help option
			echo "Usage: ./image_capture.sh [OPTION]...\n Capture images from the camera using the camera's web interface";
			echo "at given intervals.";
			echo " Only short options accepted.";
			echo "  -h,\t this help info.";
			echo "  -d,\t debug mode; messages not logged to log file but to the shell instead;";
			echo "     \t however it still captures images and saves in 'spool' directory";
			echo "  -c,\t specify configuration file/filepath. If '-c' not used,";
			echo "     \t default configuration will be used";
			echo "  -g,\t specify gap between each capture in seconds";
			echo "     \t note: if '-g' option is used along with '-c' option,";
			echo "     \t make sure '-g' option is given after '-c' option. Or else";
			echo "     \t config file from '-c' option will overwrite 'gap' value from";
			echo "     \t '-g' option";
			echo "\n Captured files are saved as:";
			echo " \t'{sensor_id}_{timestamp}.img',";
			echo " where {sensor_id} is retrieved from '/xxxxxxxxx/conf/sysid'.";
			echo ""	;
			echo " Default configuration settings (if config file is not provided):";
			echo "\t SERVICE_NAME=$SERVICE_NAME";
			echo '\t SENSOR_ID=`cat /xxxxxxxxx/conf/sysid`';	
			echo "\t CAM_URL='http://ipcam/cgi-bin/guest/Video.cgi?media=JPEG&profile=1'";
			echo "\t CAM_USER='admin'";
			echo "\t CAM_PASS='<none>'";
			echo '\t CAPTURE_GAP_DURATION=300 \t# about ~300 seconds';
			echo "\t DEST_DIR='/xxxxxxxxx/spool/'";
			echo "\t TEMP_DIR='/tmp/$SERVICE_NAME'";
			echo "\t TEMP_DIR_SIZE_LIMIT=36700160 \t# about ~35 megabytes";
			echo "\t PERL_FILE_PATH='/xxxxxxxxx/bin/'";
			echo "\t PERL_FILENAME='addtimestamp.pl'";
			echo "\t LOG_DIR='/var/log/$SERVICE_NAME/' \t# not implemented yet";
			exit 0;
			;;
		d)	# debug mode
			echo "$SERVICE_NAME: running in DEBUG mode";
			DEBUG=1;
			;;
		g)	# setting gap duration from command '-g' arguments
			CAPTURE_GAP_DURATION=$OPTARG;
			;;
		c)	# use config file
			CONF="$OPTARG";
			. $CONF; # RISKY move; can overwrite some powerful variables as well !!
			;;
		:)
			if [ "$OPTARG" = "g" ]; then
				# if no value/argument provided with '-g' option
				echo "$SERVICE_NAME: '-g' or 'gap' option requires an argument";
				echo "  -g, this option requires a value e.g. '-g 15' for 15 seconds gap";
				echo "      use option '-h' with command for more help";
			elif [ "$OPTARG" = "c" ]; then
				# if no value/argument provided with '-c' option
				echo "$SERVICE_NAME: '-c' or 'config' option requires an argument";
				echo "  -c, this option requires the configuration file path;";
				echo "      use option '-h' with command for more help";
			fi
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

# Handle process and overwriting processes
if [ -f /var/run/$SERVICE_NAME.pid ]; then
	OLD_PID=`cat /var/run/$SERVICE_NAME.pid`;
	LOG_MSG="Pid_file already exists for running process ($OLD_PID)... aborting";
	if [ $DEBUG -eq 1 ]; then
		echo; echo $LOG_MSG;
	else
		logger -t $SERVICE_NAME $LOG_MSG; 
	fi
	exit 1;
else	
	echo $$ > /var/run/$SERVICE_NAME.pid;
fi

# Creating TEMP dir if it doesn't exist; GLOBAL variable scopes
# made function just for code blocking
CREATE_TEMP_DIR ()
{
	if !( [ -d $TEMP_DIR ] ); then
		mkdir $TEMP_DIR;
		LOG_MSG="[ OK] Temp directory created: '$TEMP_DIR'";
		LOG_NOW;
	fi
	# creating a temporary directory for this session; 
	# avoids conflicts with other instances of this process
	TEMP_DIR="$(mktemp -d ${TEMP_DIR}/session.XXX)/";
}
CREATE_TEMP_DIR;

# function to clean /tmp/ dir if it is above given size (TEMP_DIR_SIZE_LIMIT)
# deletes all files with *.img extension from the temp dir
# PLUS: final cleanup i.e. remove temp session directory in temp directory
CLEAR_TMP_DIR () 
(
	FINAL_CLEANUP=$1; # if 1, final cleanup (deletes the tmp session directory)

	LOG_MSG="[CLN] Clearing tmp files at";
	if [ $FINAL_CLEANUP -eq 0 ]; then
		rm -f ${TEMP_DIR}*.img;	# only delete '*.img' files from temp session dir, does not remove the directory (YET)
		LOG_MSG="$LOG_MSG '${TEMP_DIR}'";
	else
		rm -rf "$TEMP_DIR";	# delete temp session directory (including files inside)
		LOG_MSG="$LOG_MSG '${TEMP_DIR_MAIN}'";
	fi
	LOG_NOW;
)

# Function to clear temp dir on exit; clears all *.img file from tmp dir
CLEANUP_DONE=0; # so that clean-up only happens once
CLEANUP_POST ()
(
	if [ $CLEANUP_DONE -eq 0 ]; then
		LOG_MSG=$EXIT_MSG;
		LOG_NOW;
		if [ -f /var/run/$SERVICE_NAME.pid ]; then rm /var/run/$SERVICE_NAME.pid; fi;
		CLEAR_TMP_DIR 1;
		CLEANUP_DONE=1;
	fi
)

# to capture interrupt signals and to handle the infinite main loop
# known issue: on Ctrl+C, it receives multiple signals so, CLEANUP_POST may run more than once
EXIT_LOOP=0; 
EXIT_MSG="[END] Stopped service '$SERVICE_NAME'.";
trap "	CLEANUP_POST;
	EXIT_LOOP=1;
	CLEANUP_DONE=1; " INT TERM QUIT EXIT; 
	
# Starting service; declare it in log file first
if [ $DEBUG -eq 0 ]; then
	logger -t $SERVICE_NAME "[BEG] Starting service '$SERVICE_NAME' with pid ($$)...";
fi

# Creating log dir if it doesn't exist; NOTE: custom log file NOT IMPLEMENTED YET
#if !( [ -d $LOG_DIR ] ); then
#	mkdir $LOG_DIR;
#	LOG_MSG="[ OK] Log directory created at '$LOG_DIR'";
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
		LOG_MSG="[ERR] wget: Generic error (exit status '1') at URL: '$CAM_URL'";
	elif [ $ERR_CODE -eq 2 ]; then
		LOG_MSG="[ERR] wget: Parsing error e.g. cmd-options like '.wgetrc' at URL: '$CAM_URL'";
	elif [ $ERR_CODE -eq 3 ]; then
		LOG_MSG="[ERR] wget: File I/O error at URL: '$CAM_URL'";
	elif [ $ERR_CODE -eq 4 ]; then
		LOG_MSG="[ERR] wget: Network Failure at URL: '$CAM_URL'";
	elif [ $ERR_CODE -eq 5 ]; then
		LOG_MSG="[ERR] wget: SSL verification failure at URL: '$CAM_URL'";	
	elif [ $ERR_CODE -eq 6 ]; then
		LOG_MSG="[ERR] wget: Authentication Failure at URL: '$CAM_URL'";
	elif [ $ERR_CODE -eq 7 ]; then
		LOG_MSG="[ERR] wget: Protocol errors at URL: '$CAM_URL'";		
	elif [ $ERR_CODE -eq 8 ]; then
		LOG_MSG="[ERR] wget: Server issued an error response at URL: '$CAM_URL'";		
	fi
	echo $LOG_MSG;
)

# handle add timestamp feature errors
GET_TIMESTAMP_ERROR_LOG ()
(
	STATUS_CODE=$1;
	DEST_FILE=$2;
	IMG_FILENAME=$3;
	DEST_DIR=$4;
	# PERL_FILE is global
	LOG_MSG="";
	if [ $STATUS_CODE -eq 0 ]; then
		LOG_MSG="[ OK] File saved at '$DEST_FILE'";
	else
		LOG_MSG="[ERR] Error saving file '$IMG_FILENAME' at '$DEST_DIR'. ";
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
	END_TIME=$1; # when did the capture + add timestamp process end
	
	CURRENT_TIMEMARK=$(($END_TIME/$CAPTURE_GAP_DURATION));
	CURRENT_TIMEMARK=$(($CURRENT_TIMEMARK*$CAPTURE_GAP_DURATION));
	echo $CURRENT_TIMEMARK;	# the timemark for next loop, calculated based on the END_TIME
)

MANAGE_TEMP_DIR_SPACE () 
(
	TEMP_DIR_SIZE=`du --bytes ${TEMP_DIR_MAIN} | tail -n 1 | cut -f1` 2>/dev/null;
	if [ $TEMP_DIR_SIZE -gt $TEMP_DIR_SIZE_LIMIT ]; then
		LOG_MSG="[WAR] warning: '${TEMP_DIR_MAIN}' directory size exceeds the allowed size limit of ${TEMP_DIR_SIZE_LIMIT} bytes)";
		LOG_NOW;
		CLEAR_TMP_DIR 0;
	fi
)

# pre-loop setup for variables etc
PERL_FILE="${PERL_FILE_PATH}${PERL_FILENAME}";
CURRENT_TIMEMARK=$((`date +%s`/$CAPTURE_GAP_DURATION));
CURRENT_TIMEMARK=$(($CURRENT_TIMEMARK*$CAPTURE_GAP_DURATION));

# run forever (unless signalled)
while [ $EXIT_LOOP -eq 0 ]: 
do
	TARGET_TIMEMARK=$(($CURRENT_TIMEMARK+$CAPTURE_GAP_DURATION));
	BEGIN_TIME=`date +%s`; # normally begin time = current time mark; 
	
	# Special extension *.img used for images that will be stored in 
	# both 'video' and 'preview' column in the sensor database as *.jpg
	# this is handled by: tpbacklog.pl and receiver (SensorVideoToS3.inc.php)
	IMG_FILENAME=${SENSOR_ID}_${BEGIN_TIME}.img;
	DEST_FILE="${DEST_DIR}${IMG_FILENAME}";
	TEMP_FILE="${TEMP_DIR}${IMG_FILENAME}";
	
	# check if 'temp' dir is taking too much space; if yes, clear tmp dir by deleteing all  *.img files
	MANAGE_TEMP_DIR_SPACE;
	
	# timeout period set to 2 seconds;
	wget -q --timeout=2 --user=$CAM_USER --password=$CAM_PASS $CAM_URL -O $TEMP_FILE;
	GET_STATUS=$?;
	
	if [ $GET_STATUS -eq 0 ]; then
		TIME_NOW_IN_STRING=`date '+%Y-%m-%d %H:%M:%S %Z' -d @$((BEGIN_TIME))`;
		ADD_TIMESTAMP_TO_IMAGE "$TEMP_FILE" "$TIME_NOW_IN_STRING" "$DEST_FILE"; 
		EDIT_AND_SAVE_STATUS=$?; # how did the PERL code execution (for adding timestamp) go?	
		LOG_MSG=`GET_TIMESTAMP_ERROR_LOG $EDIT_AND_SAVE_STATUS "$DEST_FILE" "$IMG_FILENAME" "$DEST_DIR"`;
	elif [ $GET_STATUS -lt 9 ] && [ $GET_STATUS -gt 0 ]; then # error code 1 to 8
		LOG_MSG=`RAISE_NETWORK_ERROR $GET_STATUS`;
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
		LOG_MSG="[WAR] warning: current image took too long to capture (more than ${CAPTURE_GAP_DURATION} secs long).";
		LOG_MSG="${LOG_MSG} Missed target timemark. Attempting to capture next image NOW.";
		LOG_NOW; 
	else
		CURRENT_TIMEMARK=$(($CURRENT_TIMEMARK+$CAPTURE_GAP_DURATION));
	fi
	
	TARGET_TIMEMARK=$(($CURRENT_TIMEMARK+$CAPTURE_GAP_DURATION));
		
	sleep $WAIT_TIME;
done
