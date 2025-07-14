#!/usr/bin/env bash
# A helper script to manage Dropbox on Linux systems
# Usage: ./dropbox-helper.sh [start|stop|status|install|uninstall
# Requires: curl, tar, python (for Dropbox daemon)
# Tested on Ubuntu/Debian systems

# Synopsis: Dropbox used to support the use of symlinks. This allowed you to link things
# you wanted to back up into the ~/Dropbox directory and Dropbox would back them up.
# This functionality was removed in 2013. This script allows you to maintain a list of
# files and directories to copy into your Dropbox folder for backup. The list is a simple
# text file with one entry per line. The script reads the list and copies the files/directories
# into a specified working directory inside your Dropbox folder. This allows you to keep
# your important files backed up without needing to move them into the Dropbox folder itself.
# The script can be run manually or set up as a cron job to run at regular intervals.

# Set up environment variables

set -euo pipefail

DROPBOX_DIR="$HOME/Dropbox"
DH_WORK_DIR_REL_PATH="dh_work"
#DH_WORK_DIR=${DROPBOX_DIR}/${DH_WORK_DIR_REL_PATH+x}
DH_FILE_LIST="$HOME/.config/dropbox-helper/dropbox-helper.lst"
INSTALLATION_MODE=false

function print_hline() {
    local char="${1:-=}"
    local length="${2:-80}"
    printf "%${length}s\n" | tr ' ' "$char"
}

function copy_file_listings() {

    while IFS= read -r line; do
        if [[ -n "$line" ]]; then
            cp --parents -a "$line" "$(work_dir_abs_path)/" 2>/dev/null || {
                echo "Warning: Could not copy '$line'. It may not exist or you may not have permission."
                continue
            }
            echo "Copied: $line to $(work_dir_abs_path)/"
        else
            echo "Skipping invalid or empty entry: $line"
        fi
    done <"$DH_FILE_LIST"
}

# ...existing code...

# ...existing code...

function show_help() {
    echo "Usage: ./dropbox-helper.sh [options]"
    echo "Options:"
    echo "  -h              Show help"
    echo "  -w <path>       Specify work directory path"
    echo "  -i              Install Dropbox Helper"
    echo "  -v              Show version number"
    echo "  -n              Dry run (no actual changes)"
}

function show_version() {
    echo "Dropbox Helper Script Version 1.0.0"
}

function work_dir_abs_path() {
    echo ${DROPBOX_DIR}/${DH_WORK_DIR_REL_PATH}
}

function have_you_installed() {
    echo "Please rerun the script with -i to install a backup list file and set up the work directory."
    echo "A sample backup list file will be created at: $DH_FILE_LIST"
    echo "You can edit this file to add files/directories you want to back up."
    echo "Example entry in the backup list file:"
    echo "/path/to/important/file_or_directory"
}

function write_sample_backup_list() {
    mkdir -p "$(dirname "$DH_FILE_LIST")"
    cat <<EOL >"$DH_FILE_LIST"
    /etc/apache2
    /etc/ssh
    ${DH_FILE_LIST}
    $HOME/.bashrc
    $HOME/.profile
    $HOME/.ssh
EOL
    echo "Sample backup list file created at: $DH_FILE_LIST"
}

#echo "WDAP: $(work_dir_abs_path)"

DRY_RUN=false

while getopts ":hw:ivd" opt; do
    case $opt in
    h)
        show_help
        exit 0
        ;;
    w)
        DH_WORK_DIR_REL_PATH="$OPTARG"
        ;;
    i)
        echo "Installing Dropbox Helper..."
        INSTALLATION_MODE=true
        ;;
    v)
        show_version
        exit 0
        ;;
    d)
        DRY_RUN=true
        ;;
    \?)
        echo "Invalid option: -$OPTARG" >&2
        show_help
        exit 1
        ;;
    :)
        echo "Option -$OPTARG requires an argument." >&2
        show_help
        exit 1
        ;;
    esac
done

if [ "$INSTALLATION_MODE" = true ]; then
    if [ -z "${DH_WORK_DIR_REL_PATH+x}" ]; then
        echo "Work directory is either unset or empty. Cannot install without a work directory."
        #have_you_installed
        exit 1
    fi

    if [ "${DH_WORK_DIR_REL_PATH:0:2}" == ".." ]; then
        echo "Work directory must be a subdirectory of your Dropbox folder."
        echo "You provided: ${DH_WORK_DIR_REL_PATH}"
        #have_you_installed
        exit 1
    fi

    if [ -z "$DH_WORK_DIR_REL_PATH" ]; then
            echo "Work directory relative path is not set. Cannot proceed with installation."
            exit 1
    fi

    

    if $DRY_RUN; then
        echo "Dry run enabled. No changes will be made."        
        echo "Would create sample backup list file at: $DH_FILE_LIST"
    else        
        mkdir -p "$(work_dir_abs_path)"
        echo "Created work directory: $(work_dir_abs_path)"
        write_sample_backup_list
        echo "Installation complete. Please edit the backup list file and rerun the script without -
i to perform backups."
        echo "Work directory is set to: $(work_dir_abs_path)"
        echo "You can change this by rerunning the script with -w <relative_path>"
        echo "Example: ./dropbox-helper.sh -i -w my_backup_dir"
        echo "Note: The work directory is relative to your Dropbox folder."
        echo "Example full path: $(work_dir_abs_path)"
    fi

else
    if [[ ! -f "$DH_FILE_LIST" ]]; then
        echo "Backup list file not found: $DH_FILE_LIST"
        #print_hline "="
        print_hline
        have_you_installed
        exit 1
    fi
fi

# ...existing code...
