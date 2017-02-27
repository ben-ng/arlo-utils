shopt -s nullglob

# Unfortunately, the filenames of the recordings might get the hour wrong.
# They're always an hour early on my system. So we should instead rely on
# when the file was created. However, the file is created _after_ the
# recording starts, because there's some lag between the camera and the
# base station. So we need to correct for that lag. We can safely (I think)
# assume that the lag is going to be less than an hour.
function get_lag_between_event_and_recording {
  # To get around the issue of spaces in filenames
  FILE_CREATED_TIME=$1
  FILENAME=$2

  # Parse the file created time
  FILE_CREATED_HOUR=$(echo $FILE_CREATED_TIME | rev | cut -c7-8 | rev)
  FILE_CREATED_MINUTE=$(echo $FILE_CREATED_TIME | rev | cut -c4-5 | rev)
  FILE_CREATED_SECOND=$(echo $FILE_CREATED_TIME | rev | cut -c1-2 | rev)
  FILE_CREATED_SECONDS_FROM_TOP_OF_HOUR=$(($FILE_CREATED_MINUTE * 60 + $FILE_CREATED_SECOND))

  # Parse the filename to get the recording time
  RECORDED_MINUTE=$(echo $FILENAME | rev | cut -c7-8 | rev)
  RECORDED_SECOND=$(echo $FILENAME | rev | cut -c5-6 | rev)
  RECORDED_SECONDS_FROM_TOP_OF_HOUR=$(($RECORDED_MINUTE * 60 + $RECORDED_SECOND))

  LAG_IN_SECONDS=$(($FILE_CREATED_SECONDS_FROM_TOP_OF_HOUR - $RECORDED_SECONDS_FROM_TOP_OF_HOUR))

  # If the recording started at 23:59:59 but the file was created at 00:00:00 then the above result
  # would be -3599... But we always want positive lag numbers.
  SECONDS_IN_ONE_HOUR=3600
  LAG_IN_SECONDS=$((($LAG_IN_SECONDS + $SECONDS_IN_ONE_HOUR) % 3600))

  # For debugging
  # printf "File created time: $FILE_CREATED_TIME\n"
  # printf "Recording filename: $FILENAME\n"
  # printf "Lag: $LAG_IN_SECONDS seconds\n"

  printf "$LAG_IN_SECONDS"
}

function get_recording_start_epoch_of_file {
  FILENAME=$1

  FILE_CREATED_TIME=$(GetFileInfo -d $FILENAME)
  FILE_CREATED_EPOCH=$(date -j -f "%m/%d/%Y %H:%M:%S" "$FILE_CREATED_TIME" +%s)

  RECORDING_LAG=$(get_lag_between_event_and_recording "${FILE_CREATED_TIME}" "${FILENAME}")
  FILE_RECORDED_EPOCH=$(($FILE_CREATED_EPOCH-$RECORDING_LAG))

  printf "$FILE_RECORDED_EPOCH"
}

function get_recording_start_time_of_file {
  FILENAME=$1
  FILE_RECORDED_EPOCH=$(get_recording_start_epoch_of_file "${FILENAME}")
  FILE_RECORDED_TIME=$(date -r $FILE_RECORDED_EPOCH "+%m/%d/%Y %H:%M:%S")
  printf "$FILE_RECORDED_TIME"
}

function get_recording_date_of_file {
  FILENAME=$1
  FILE_RECORDED_TIME=$(get_recording_start_time_of_file "${FILENAME}")
  FILE_RECORDED_DATE=$(echo $FILE_RECORDED_TIME | cut -c1-10)
  printf "$FILE_RECORDED_DATE"
}

function get_camera_id_of_file {
  FILENAME=$1
  CAMERA_ID=$(echo $FILENAME | cut -d_ -f1)
  printf "$CAMERA_ID"
}

function transcode_and_add_timecode_to_file {
  INPUT_FILE=$1
  OUTPUT_FILE=$2

  FILE_RECORDED_EPOCH=$(get_recording_start_epoch_of_file "${INPUT_FILE}")

  ffmpeg -loglevel panic \
    -i $INPUT_FILE \
    -vf "drawtext=fontfile=/System/Library/Fonts/Menlo.ttc: \
    text='%{pts\:localtime\:$FILE_RECORDED_EPOCH}': \
    x=7: y=700: \
    fontcolor=white@1: \
    borderw=1: bordercolor=black" \
    -vcodec libx264 \
    -preset veryfast -f mp4 -y $OUTPUT_FILE
}

function transcode_files_to_folder {
  INPUT_FOLDER=$1
  OUTPUT_FOLDER=$2

  for FILE in "${INPUT_FOLDER}/*.mp4"
  do
    DESTINATION_FOLDER_NAME=$(get_recording_date_of_file "${FILE}")
    DESTINATION_FILE_NAME=$(get_recording_start_epoch_of_file "${FILE}")
    mkdir -p "${OUTPUT_FOLDER}/${DESTINATION_FOLDER_NAME}"
  done
}
