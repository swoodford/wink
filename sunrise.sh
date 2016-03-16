#!/usr/bin/env bash

# This script uses the Wink API to give a lightbulb a sunrise effect over 10 minutes
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
	echo "$APIURL"/light_bulb/"$1"
	# pause
	updateLightbulb=$(curl -sX PUT "$APIURL"/light_bulb/"$1" \
		-H "Authorization: Bearer $access_token" \
		-H "Content-Type: application/json" \
		--data-binary '{
			"desired_state": {
				"powered": "'"$2"'",
				"brightness": "'"$3"'"
			}
		}')
	echo $updateLightbulb # | jq .
	# pause

	result=$(echo $updateLightbulb | jq '.errors != null')

	if [[ "$result" == "0" ]]; then
		name=$(echo $updateLightbulb | jq '.data | .name')
		tput setaf 2; echo $name Successful && tput sgr0
	else
		failwithoutexit $(echo $updateLightbulb | jq '.errors')
	fi
}

function sunrise(){
	echo Sunrise Effect on Lightbulb over 10 minutes...

	for ((i=0; i < 101; i += 1))
	do
		echo brightnesslevel: "scale=2; ${i}/100" | bc
		brightnesslevel=$(echo "scale=2; ${i}/100" | bc)
		updateLightbulb $bulbid true $brightnesslevel
		sleep 6

	done
}

# Check required commands
check_command "bc"
check_command "jq"

# Get Token
getToken

# retrieveLightBulbIDs

bulbid="xxxxxxxx"
brightnesslevel="0"

updateLightbulb $bulbid true $brightnesslevel

# Sunrise
# sunrise
