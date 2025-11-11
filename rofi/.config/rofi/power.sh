#!/usr/bin/env bash
options=" Lock\n⏾ Suspend\n Reboot\n Power off"
chosen=$(echo -e "$options" | rofi -dmenu -p "Power" -theme catppuccin-mocha)
case "$chosen" in
    " Lock") hyprlock ;;

    "⏾ Suspend") systemctl suspend ;;
    " Reboot") systemctl reboot ;;
    " Power off") systemctl poweroff ;;
esac
