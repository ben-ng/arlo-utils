#!/usr/bin/env bash

# Import the library of helper functions
source ./lib.sh

# We need
FIXTURE_FILE=5FO00B3ABC1A1_000000b0_20170223_172955.mp4
TMP_FIXTURE_FILE="/tmp/$FIXTURE_FILE"

# Print results straight to stdout.
# Assert with diff later.

printf "Lag between event and recording: \
$(get_lag_between_event_and_recording "02/23/2017 18:30:24" ${FIXTURE_FILE})\n"

printf "Lag between event and recording when hour is wrong: \
$(get_lag_between_event_and_recording "02/23/2017 18:30:24" ${FIXTURE_FILE})\n"

printf "Lag between event and recording across midnight: \
$(get_lag_between_event_and_recording "02/24/2017 00:00:00" ${FIXTURE_FILE})\n"

printf "Lag between event and recording when hour is wrong, across midnight: \
$(get_lag_between_event_and_recording "02/24/2017 00:00:00" ${FIXTURE_FILE})\n"

# Set the file's modified and created dates, so that this test is repeatable
touch -t 201702231830.24 $TMP_FIXTURE_FILE

printf "Recording start epoch of file: \
$(get_recording_start_epoch_of_file ${TMP_FIXTURE_FILE})\n"

printf "Recording start time of file: \
$(get_recording_start_time_of_file ${TMP_FIXTURE_FILE})\n"

printf "Recording date of file: \
$(get_recording_date_of_file ${TMP_FIXTURE_FILE})\n"

unlink $TMP_FIXTURE_FILE

printf "Camera ID of file: \
$(get_camera_id_of_file ${FIXTURE_FILE})\n"
