#!/usr/bin/env bash

# Source global control script
scrDir=$(dirname "$(realpath "$0")")
# shellcheck disable=SC1091
source "$scrDir/globalcontrol.sh"
confDir=${confDir:-$XDG_CONFIG_HOME}

# Check if SwayOSD is installed
use_swayosd=false
isNotify=${VOLUME_NOTIFY:-true}
if command -v swayosd-client >/dev/null 2>&1 && pgrep -x swayosd-server >/dev/null; then
    use_swayosd=true
fi
isVolumeBoost="${VOLUME_BOOST:-false}"
# Define functions


notify_bluelight() {
    local vol=$1
    angle=$((((vol + 2) / 5) * 5))
    iconStyle="knob"
    # cap the icon at 100 if vol > 100
    [ "$angle" -gt 100 ] && angle=100
    ico="${icodir}/${iconStyle}-${angle}.svg"
    bar=$(seq -s "." $((vol / 15)) | sed 's/[0-9]//g')
    [[ "${isNotify}" == true ]] && notify-send -a "HyDE Notify" -r 8 -t 800 -i "${ico}" "${vol}${bar}" "Blue Light Filter"
}

notify_disable() {
    notify-send -a "HyDE Notify" -r 8 -t 800 -i "Blue Light Filter Disabled"
}

change_intensity() {
    local action=$1
    local step=$2

    if [ "${action}" = "i" ]; then
        /usr/bin/wl-gammarelay-rs | busctl --user -- call rs.wl-gammarelay / rs.wl.gammarelay UpdateTemperature n -"${step}"
    else busctl --user -- call rs.wl-gammarelay / rs.wl.gammarelay UpdateTemperature n +"${step}"
    fi

    notify_bluelight "$vol"
}

disable() {
    local device=$1
    local mode="--output-volume"
    [ "${srce}" = "--default-source" ] && mode="--input-volume"
    case $device in
    "pamixer")
        $use_swayosd && swayosd-client "${mode}" mute-toggle && exit 0
        pamixer "$srce" -t
        notify_mute
        ;;
    "playerctl")
        local volume_file
        volume_file="/tmp/$(basename "$0")_last_volume_${srce:-all}"
        if [ "$(playerctl --player="$srce" volume | awk '{ printf "%.2f", $0 }')" != "0.00" ]; then
            playerctl --player="$srce" volume | awk '{ printf "%.2f", $0 }' >"$volume_file"
            playerctl --player="$srce" volume 0
        else
            if [ -f "$volume_file" ]; then
                last_volume=$(cat "$volume_file")
                playerctl --player="$srce" volume "$last_volume"
            else
                playerctl --player="$srce" volume 0.5 # Default to 50% if no saved volume
            fi
        fi
        notify_mute
        ;;
    esac
}


# Main script logic
icodir="${iconsDir}/Wallbash-Icon/media"
temp=6500

# Set default variables
iconsDir="${iconsDir:-$XDG_DATA_HOME/icons}"
step=${INTENSITY_STEPS:-500}

# while getopts "iop:stq" opt; do
#     case $opt in
#     i)
#         device="pamixer"
#         srce="--default-source"
#         nsink=$(pamixer --list-sources | awk -F '"' 'END {print $(NF - 1)}')
#         ;;
#     o)
#         device="pamixer"
#         srce=""
#         nsink=$(pamixer --get-default-sink | awk -F '"' 'END{print $(NF - 1)}')
#         ;;
#     p)
#         device="playerctl"
#         srce="${OPTARG}"
#         nsink=$(playerctl --list-all | grep -w "$srce")
#         ;;
#     s)
#         if ! selected_output=$(hyprland-dialog --text "$(
#             echo -e "Devices:"
#             select_output | sed 's/^/           🔈 /'
#         )" \
#             --title "Choose an output device" \
#             --buttons "$(select_output | sed 's/$/;/')"); then
#             selected_output=$(select_output | rofi -dmenu -theme "notification")
#         fi
#         select_output "${selected_output}"
#         exit
#         ;;
#     t)
#         toggle_output
#         exit
#         ;;
#     q)
#         isNotify=false
#         ;;
#     *) print_usage ;;
#     esac
# done

# shift $((OPTIND - 1))

# # Check if device is set
# [ -z "$device" ] && print_usage

# Execute action
case $1 in
i | d) change_intensity "$1" "${2:-$step}" ;;
m) toggle_mute "$device" ;;
*) print_usage ;;
esac
