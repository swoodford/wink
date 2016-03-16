#!/usr/bin/env bash

# This script uses the Wink API to turn on a lightbulb with a sunrise effect by gradually increasing bulb brightness over time
# Requires jq, curl

# Set credentials
. ./set-credentials.sh

# Functions
function check_command {
	type -P $1 &>/dev/null || fail "Unable to find $1, please install it and run this script again."
}

function fail(){
	tput setaf 1; echo "Failure: $*" && tput sgr0
	exit 1
}

function failwithoutexit(){
	tput setaf 1; echo "Failure: $*" && tput sgr0
}

function pause(){
	read -p "Press any key to continue..."
	echo
}

# Retrieve list of all lightbulbs
function retrieveLightBulbIDs(){
	retrieveLightBulbIDs=$(curl -s "$APIURL"/users/me/light_bulbs \
		-H "Authorization: Bearer $access_token")

	bulbIDs=$(echo $retrieveLightBulbIDs | jq . | grep light_bulb_id | cut -d \" -f4)
	totalBulbs=$(echo "$bulbIDs" | wc -l)
	# echo Total Bulbs: "$totalBulbs"
	bulbNames=$(echo $retrieveLightBulbIDs | jq . | grep -w name | cut -d \" -f4)

	START=1
	for (( COUNT=$START; COUNT<=$totalBulbs; COUNT++ ))
	do
		echo "====================================================="
		echo \#$COUNT
		thisBulbID=$(echo "$bulbIDs" | nl | grep -w $COUNT | cut -f 2)
		echo "Bulb ID: "$thisBulbID
		thisBulbName=$(echo "$bulbNames" | nl | grep -w $COUNT | cut -f 2)
		echo "Bulb Name: "$thisBulbName

	# echo "$bulbIDs"
	# echo "$bulbNames"
	# pause
	done
}

# Turn a light bulb on or off and set brightness level
function updateLightbulb(){
	updateLightbulb=$(curl -sX PUT "$APIURL"/light_bulbs/"$1" \
		-H "Authorization: Bearer $access_token" \
		-H "Content-Type: application/json" \
		--data-binary '{
			"desired_state": {
				"powered": "'"$2"'",
				"brightness": "'"$3"'"
			}
		}')
	# echo $updateLightbulb | jq .
	# pause

	result=$(echo $updateLightbulb | jq '.errors != null')

	if [ $result = "true" ]; then
		name=$(echo $updateLightbulb | jq '.data | .name' | cut -d \" -f2)
		tput setaf 2; echo $name: $brightnesslevel && tput sgr0
	else
		failwithoutexit $(echo $updateLightbulb | jq '.errors')
	fi
}

# The actual brightness level maxes out around 0.30 with an interval increase of .005
function sunrise(){
	echo Starting sunrise effect on lightbulb over 20 minutes...

	for ((i=0; i < 301; i += 5))
	do
		# echo brightnesslevel: "scale=2; ${i}/100" | bc
		brightnesslevel=$(echo "scale=3; ${i}/1000" | bc)
		# echo $brightnesslevel
		updateLightbulb $bulbid true $brightnesslevel
		sleep 20
	done
	brightnesslevel="1.0"
	updateLightbulb $bulbid true $brightnesslevel
}

# Check required commands
check_command "bc"
check_command "curl"
check_command "jq"

# Get Token
getToken

# retrieveLightBulbIDs

# Manually set Bulb ID
bulbid="xxxxxxx"
# brightnesslevel="0"

# updateLightbulb $bulbid true $brightnesslevel

# Sunrise
sunrise
