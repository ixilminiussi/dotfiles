#!/usr/bin/bash

# Nuke all internal spawns when script dies
trap "trap - SIGTERM && kill -- -$$" SIGINT SIGTERM

BARS=8;
FRAMERATE=60;
EQUILIZER=1;

# Get script options
while getopts 'b:f:m:eh' flag; do
    case "${flag}" in
        b) BARS="${OPTARG}" ;;
        f) FRAMERATE="${OPTARG}" ;;
        e) EQUILIZER=0 ;;
        h)
            echo "caway usage: caway [ options ... ]"
            echo "where options include:"
            echo
            echo "  -b <integer>  (Number of bars to display. Default 8)"
            echo "  -f <integer>  (Framerate of the equilizer. Default 60)"
            echo "  -e            (Disable equilizer. Default enabled)"
            echo "  -h            (Show help message)"
            exit 0
            ;;
    esac
done

bar="▁▂▃▄▅▆▇█"
dict="s/;//g;"

# creating "dictionary" to replace char with bar + thin space " "
i=0
while [ $i -lt ${#bar} ]
do
    dict="${dict}s/$i/${bar:$i:1}/g;"
    i=$((i=i+1))
done

# Remove last extra thin space
dict="${dict}s/.$//;"

clean_create_pipe() {
    if [ -p $1 ]; then
        unlink $1
    fi
    mkfifo $1
}

kill_pid_file() {
    if [[ -f $1 ]]; then
        while read pid; do
            { kill "$pid" && wait "$pid"; } 2>/dev/null
        done < $1
    fi
}

# PID of the cava process and while loop launched from the script
cava_waybar_pid="/tmp/cava_waybar_pid"
scroll_waybar_pid="/tmp/scroll_waybar_pid"

# Clean pipe for cava
cava_waybar_pipe="/tmp/cava_waybar.fifo"
clean_create_pipe $cava_waybar_pipe

# Custom cava config
cava_waybar_config="/tmp/cava_waybar_config"
echo "
[general]
mode = normal
framerate = $FRAMERATE
bars = $BARS

[output]
method = raw
channels = mono
raw_target = $cava_waybar_pipe
data_format = ascii
ascii_max_range = 7
" > $cava_waybar_config

# Clean pipe for playerctl
playerctl_waybar_pipe="/tmp/playerctl_waybar.fifo"
clean_create_pipe $playerctl_waybar_pipe

# playerctl output into playerctl_waybar_pipe
playerctl -a metadata --format '{"text": "{{artist}} - {{title}}", "tooltip": "{{playerName}} : {{markup_escape(artist)}} - {{markup_escape(title)}}", "alt": "{{status}}", "class": "{{status}}"}' -F >$playerctl_waybar_pipe &

# Read the playerctl o/p via its fifo pipe
while read -r line; do
    # Kill any previous cava processes
    kill_pid_file $cava_waybar_pid

    song_text=$(echo "$line" | jq -r '.text')
    player_status=$(echo "$line" | jq -r '.class')

    # Start panning if text longer than bars
    if (( ${#song_text} > $BARS )); then
        (
            while true; do
                for ((offset=0; offset<${#song_text}; offset++)); do
                    display_text=${song_text:offset:BARS}
                    if (( ${#display_text} < $BARS )); then
                        remainder=$((BARS - ${#display_text}))
                        display_text+="${song_text:0:remainder}"
                    fi
                    # Only echo if bars aren't playing
                    if [[ ! -p $cava_waybar_pipe || ! $(pgrep -f "cava -p $cava_waybar_config") ]]; then
                        echo "$line" | jq --arg a "$display_text" \
                            '.text = $a' --unbuffered --compact-output
                    fi
                    sleep 0.2
                done
            done
        ) &
        echo $! > $scroll_waybar_pid
    else
        echo "$line" | jq --arg a "$song_text" \
            '.text = $a' --unbuffered --compact-output
    fi

    # If playing and equalizer is enabled → show bars
    if [[ $EQUILIZER == 1 && $player_status == 'Playing' ]]; then
        sleep 2  # short delay before bars

        # Kill panning now that bars start
        kill_pid_file $scroll_waybar_pid

        cava -p $cava_waybar_config >$cava_waybar_pipe &
        echo $! > $cava_waybar_pid

        while read -r cmd2; do
            echo "$line" | jq --arg a "$(echo "$cmd2" | sed "$dict")" \
                '.text = $a' --unbuffered --compact-output
        done < $cava_waybar_pipe &
        echo $! >> $cava_waybar_pid
    fi
done < $playerctl_waybar_pipe
