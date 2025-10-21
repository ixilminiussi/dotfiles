#!/usr/bin/env bash
# Nuke all internal spawns when script dies
trap "trap - SIGTERM && kill -- -$$" SIGINT SIGTERM

BARS=8
FRAMERATE=60
EQUILIZER=1

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
while [ $i -lt ${#bar} ]; do
    dict="${dict}s/$i/${bar:$i:1}/g;"
    i=$((i + 1))
done

# Remove last extra thin space
dict="${dict}s/.$//;"

clean_create_pipe() {
    local p="$1"
    if [ -p "$p" ]; then
        unlink "$p" 2>/dev/null || rm -f "$p"
    fi
    mkfifo "$p"
}

kill_pid_file() {
    local f="$1"
    if [[ -f "$f" ]]; then
        while read -r pid; do
            if [[ -n "$pid" ]]; then
                { kill "$pid" 2>/dev/null && wait "$pid" 2>/dev/null; } || true
            fi
        done < "$f"
        rm -f "$f"
    fi
}

pidfile_has_live_pids() {
    local f="$1"
    [[ -f "$f" ]] || return 1
    while read -r pid; do
        [[ -n "$pid" ]] || continue
        if kill -0 "$pid" 2>/dev/null; then
            return 0
        fi
    done < "$f"
    return 1
}

# PID files
cava_waybar_pid="/tmp/cava_waybar_pid"
scroll_waybar_pid="/tmp/scroll_waybar_pid"

# FIFOs
cava_waybar_pipe="/tmp/cava_waybar.fifo"
playerctl_waybar_pipe="/tmp/playerctl_waybar.fifo"

# Create FIFOs
clean_create_pipe "$cava_waybar_pipe"
clean_create_pipe "$playerctl_waybar_pipe"

# Custom cava config
cava_waybar_config="/tmp/cava_waybar_config"
cat > "$cava_waybar_config" <<EOF
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
EOF

# Start playerctl (line-buffered) writing into fifo
# Use stdbuf to avoid blocked buffering surprises
stdbuf -oL playerctl -a metadata --format '{"text": "{{artist}} - {{title}}", "tooltip": "{{playerName}} : {{markup_escape(artist)}} - {{markup_escape(title)}}", "alt": "{{status}}", "class": "{{status}}"}' -F >"$playerctl_waybar_pipe" &

PLAYERCTL_PID=$!
# Ensure it dies with us
echo "$PLAYERCTL_PID" >/tmp/caway_playerctl.pid

# Manage cava / scroll lifecycle
stop_cava() {
    kill_pid_file "$cava_waybar_pid"
    clean_create_pipe "$cava_waybar_pipe"
}

start_cava_with_line() {
    local line_json="$1"

    # ensure scroll isn't running and cava is restarted cleanly
    stop_scroll
    stop_cava

    # start cava writer
    cava -p "$cava_waybar_config" >"$cava_waybar_pipe" &
    echo $! > "$cava_waybar_pid"

    # start cava reader; capture the line at spawn time so it stays in sync
    local spawn_line="$line_json"
    (
        while read -r cmd2; do
            # translate ascii bars into glyphs and inject into the JSON we were given
            echo "$spawn_line" | jq --arg a "$(echo "$cmd2" | sed "$dict")" '.text = $a' --unbuffered --compact-output
        done <"$cava_waybar_pipe"
    ) &
    echo $! >> "$cava_waybar_pid"
}

stop_scroll() {
    kill_pid_file "$scroll_waybar_pid"
}

start_scroll_with_line_and_text() {
    local line_json="$1"
    local song_text="$2"

    stop_scroll

    # spawn the panning loop as a background process and record pid
    (
        local start_time
        start_time=$(date +%s.%N)
        local speed=5
        while true; do
            local now elapsed offset display_text remainder
            now=$(date +%s.%N)
            elapsed=$(echo "$now - $start_time" | bc -l)
            offset=$(printf "%.0f" "$(echo "$elapsed * $speed" | bc -l)")
            offset=$((offset % ${#song_text}))

            display_text="${song_text:offset:BARS}"
            if (( ${#display_text} < BARS )); then
                remainder=$((BARS - ${#display_text}))
                display_text+="${song_text:0:remainder}"
            fi

            # Only output panning text if cava isn't running
            if ! pidfile_has_live_pids "$cava_waybar_pid"; then
                echo "$line_json" | jq --arg a "$display_text" '.text = $a' --unbuffered --compact-output
            fi

            sleep 0.05
        done
    ) &
    echo $! > "$scroll_waybar_pid"
}

# Main reader loop: read from playerctl fifo and react
LAST_LINE=""
while read -r line; do
    # If playerctl died, break
    if ! kill -0 "$PLAYERCTL_PID" 2>/dev/null; then
        break
    fi

    # parse
    song_text=$(echo "$line" | jq -r '.text')
    player_status=$(echo "$line" | jq -r '.class')

    # if playing & eq enabled -> ensure cava is running and shows bars
    if [[ $EQUILIZER == 1 && $player_status == "Playing" ]]; then
        # if cava not running or song changed, restart cava so the injected JSON matches latest metadata
        if ! pidfile_has_live_pids "$cava_waybar_pid" || [[ "$line" != "$LAST_LINE" ]]; then
            start_cava_with_line "$line"
        else
            # cava is running and same song -> nothing to do
            :
        fi

    else
        # Not playing or eq disabled -> ensure cava is stopped and show text (pan if long)
        stop_cava

        if (( ${#song_text} > BARS )); then
            # ensure a single scroll process represents the current text; restart if metadata changed
            if ! pidfile_has_live_pids "$scroll_waybar_pid" || [[ "$line" != "$LAST_LINE" ]]; then
                start_scroll_with_line_and_text "$line" "$song_text"
            fi
        else
            # short text -> stop scroll and output static line
            stop_scroll
            echo "$line" | jq --arg a "$song_text" '.text = $a' --unbuffered --compact-output
        fi
    fi

    LAST_LINE="$line"
done < "$playerctl_waybar_pipe"
