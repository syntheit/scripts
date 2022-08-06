#! /bin/bash

# This is a script that will clean up the naming schemes for TV shows using a standard format
# It will check for subdirectories of the parent directory

# Example:
# Original: Better.Call.Saul.S06E09.1080p.WEB.H264-GLHF
# Result: Better Call Saul S06E09

# The name of the show must be specified with --name

name=""
directory=""
og_dir=$PWD
declare -A supported_extensions=( ["mkv"]="mkv" ["mp4"]="mp4" ["srt"]="srt" )

function batchRenamerHelp() {
    echo "Daniel's Batch Renamer"
    echo "--help - Displays help message"
    echo "--name - The show name to append to the episode titles"
}


function rename() {
    i=0
    for dir in */; do
        cd "$og_dir/$dir"
        for file in {.*,*}; do
            if [[ $file == *S+([0-9])E+([0-9])* ]]; then
                extension=${file##*.}
                if [[ $extension == "${supported_extensions[$extension]}" ]]; then
                    newname=$(echo $name $(echo $file | grep -Eo 'S[0-9]+E[0-9]+').$extension)
                    if [[ "$file" != "$newname" ]]; then
                        mv "$file" "$newname"
                        ((i++))
                    fi
                fi
            fi
        done
    done
    echo "$i files renamed"
}

while [ "$1" != "" ]; do
    case $1 in
        -n | --name )
            name="$2"
            rename
        ;;
        -h | --help )
            batchRenamerHelp
            exit
        ;;
        * )
            echo "Invalid argument
            "
            batchRenamerHelp
            exit 0
    esac
    shift
done