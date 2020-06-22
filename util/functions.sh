#!/bin/bash
# SPDX-License-Identifier: GPL-3.0+
# Copyright (C) 2018, Martin Kepplinger <martink@posteo.de>
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

FLASHROM=$(whereis -b flashrom | cut -d ' ' -f 2)
DMIDECODE=$(whereis -b dmidecode | cut -d ' ' -f 2)

force_x230_and_root()
{
	if [ "$EUID" -ne 0 ] ; then
		echo -e "${RED}Please run this as root.${NC} And make sure you have the following programs:"
		echo "dmidecode"
		echo "flashrom"

		exit 1
	fi

	local LAPTOP=$(${DMIDECODE} | grep -i x230 | sort -u)
	if [ -z "$LAPTOP" ] ; then
		echo "This is no Thinkpad X230. This script is useless then."
		exit 0
	fi
}

check_battery() {
	local capacity=$(cat /sys/class/power_supply/BAT*/capacity 2>/dev/null || echo -ne "0")
	local online=$(cat /sys/class/power_supply/AC/online 2>/dev/null || cat /sys/class/power_supply/ADP*/online 2>/dev/null || echo -ne "0")
	local failed=0

	if [ "${online}" == "0" ] ; then
		failed=1
	fi
	if [ "${capacity}" -lt 25 ]; then
		failed=1
	fi
	if [ $failed == "1" ]; then
		echo -e "${YELLOW}WARNING:${NC} To prevent shutdowns, we recommend to only run this script when"
		echo "         your laptop is plugged in to the power supply AND"
		echo "         the battery is present and sufficiently charged (over 25%)."
		while true; do
			read -r -p "Continue anyways? (please do NOT!) y/N: " yn
			case $yn in
				[Yy]* ) break;;
				[Nn]* ) exit;;
				* ) exit;;
			esac
		done
	fi
}

warn_not_root() {
	if [[ $EUID -eq 0 ]]; then
		echo -e "${YELLOW}WARNING:${NC} This should not be executed as root!"
	fi
}

poweroff() {
    if [ "$(command -v systemctl 2>/dev/null 2>&1)" ]; then
        systemctl poweroff
    else
        shutdown -P now
    fi
}
