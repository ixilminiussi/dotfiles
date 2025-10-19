#!/bin/bash
if bluetoothctl show | grep -q "Powered: yes"; then
    device=$(bluetoothctl info | grep "Alias" | cut -d ' ' -f2-)
    if [ -z "$device" ]; then
        echo '{"text": "On", "class": "on", "alt": "on", "tooltip": "Bluetooth On (no device connected)", "icon": ""}'
    else
        echo '{"text": "'"$device"'", "class": "on", "alt": "on", "tooltip": "Connected to '"$device"'", "icon": ""}'
    fi
else
    echo '{"text": "Off", "class": "off", "alt": "off", "tooltip": "Bluetooth Off", "icon": "󰂲"}'
fi

