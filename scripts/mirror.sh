#!/bin/bash

# A script to mirror files to a remote backup server using rsync
set -euo pipefail # Exit on error, undefined variable, or pipe failure
REMOTE_HOST="greg@hc"
SYNC_LOG="mirror_sync.log"
TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
#dirs=("Dropbox" "Projects" "backup-test")

#LOCAL_DIRECTORY="$HOME/backup-test"
#echo "Starting sync of ${LOCAL_DIRECTORY}/ to ${REMOTE_HOST}:${LOCAL_DIRECTORY}"

#CMD="rsync -avz --delete --progress ${LOCAL_DIRECTORY}/ ${REMOTE_HOST}:${LOCAL_DIRECTORY}"
#echo "Running: $CMD"
#echo "Synced: ${LOCAL_DIRECTORY}/ to ${REMOTE_HOST}:${LOCAL_DIRECTORY}"

files=("Writing" "backup-test" "Dropbox" "Projects")
symlinks=("2025" "BUSINESS" "IR2F" "NWM" "OSF" "homepage")
websites=("gregorypropf.com" "implicitpixels.com-dev")
WEB_ROOT="/var/www"

# for d in "${dirs[@]}"; do
#   CMD="rsync -avz --delete --partial --progress $HOME/$d ${REMOTE_HOST}:"
#   echo "Running: $CMD"
#   $CMD || {
#     echo "Warning: Could not sync '$HOME/$d' to '${REMOTE_HOST}:$d'. It may not exist or you may not have permission." | tee SYNC_HAD_ERRORS
#     exit 1
#   }
#   echo "${TIMESTAMP}: Synced: '$HOME/$d' to '${REMOTE_HOST}:$d'" | tee -a ${SYNC_LOG}
# done

function sync_files {
  local root_dir="$1"
  shift
  local -a files_to_sync=("${@}")
  #local FILES=$1
  echo "------------------------------------------------------------------" | tee -a ${SYNC_LOG}
  echo "${TIMESTAMP}: Root dir: $root_dir" | tee -a ${SYNC_LOG}
  echo "${TIMESTAMP}: Files to sync: ${files_to_sync[*]}" | tee -a ${SYNC_LOG}
  for d in "${files_to_sync[@]}"; do
    CMD="rsync -avz --delete --partial --progress $root_dir/$d ${REMOTE_HOST}:$root_dir/"
    TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
    echo "${TIMESTAMP}: Running: $CMD"
    $CMD || {
      echo "Warning: Could not sync '$root_dir/$d' to '${REMOTE_HOST}:$root_dir/$d'. It may not exist or you may not have permission." | tee SYNC_HAD_ERRORS
      exit 1
    }
    echo "${TIMESTAMP}: Synced: '$HOME/$d' to '${REMOTE_HOST}:$root_dir/$d'" | tee -a ${SYNC_LOG}
  done

}

sync_files $HOME "${files[@]}"
sync_files $HOME "${symlinks[@]}"
sync_files $WEB_ROOT "${websites[@]}"
TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
echo "${TIMESTAMP}: Mirror sync completed successfully!!" | tee -a ${SYNC_LOG}


