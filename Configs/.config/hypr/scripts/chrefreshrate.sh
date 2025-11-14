#!/bin/bash

# Define your monitor you can get it by typing hyprctl monitor
MONITOR="HDMI-A-2"


CURRENT_RATE=$(hyprctl monitors | grep "$MONITOR" | grep -o '[0-9.]*Hz' | sed 's/Hz//')


# Define your two refresh rates you want to toggle between
RATE1="120.002998"
RATE2="60.001999"


if [ "$(echo $CURRENT_RATE | bc)" == "$(echo $RATE1 | bc)" ]; then
  hyprctl keyword monitor $MONITOR,3840x2160@$RATE2,auto,2.6667, bitdepth, 10, vrr, 0
else
  hyprctl keyword monitor $MONITOR,3840x2160@$RATE1,auto,2.6667, bitdepth, 10, vrr, 0
fi
