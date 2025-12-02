#!/bin/bash

if lsusb | grep -qi "Xbox"; then
	echo " <span foreground=\"#8b5cf6\" size=\"140%\">󰖺</span>     "
else 
	bt_info=$(bluetoothctl info)
	if echo "$bt_info" | grep -q Xbox; then
		battery=$(echo "$bt_info" | grep 'Battery Percentage:' | awk -F'[()]' '{ print $2 }')
		echo " <span foreground=\"#8b5cf6\" size=\"140%\">󰖺</span>   ${battery}% "
	else
		echo " <span foreground=\"#8b5cf6\" size=\"140%\">󰖻</span>     "
	fi
fi
