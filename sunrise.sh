#!/usr/bin/env bash
# This script uses the Wink API

# This script uses the Wink API to control IOT enabled devices
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

function getToken(){
	getToken=$(curl -sX POST "$APIURL"oauth2/token \
		-H "Content-Type: application/json" \
		-d '
		{
			"client_id": "'"$client_id"'",
	    	"client_secret": "'"$client_secret"'",
		    "username": "'"$username"'",
		    "password": "'"$password"'",
		    "grant_type": "password"
		} ')

	# echo $getToken | jq .
	access_token=$(echo $getToken | jq '.access_token' | cut -d '"' -f 2)
	# echo $access_token
	refresh_token=$(echo $getToken | jq '.refresh_token' | cut -d '"' -f 2)
	# echo $refresh_token
}

function retrieveLightBulbIDs(){
	retrieveLightBulbIDs=$(curl -s "$APIURL"/users/me/light_bulbs \
		-H "Authorization: Bearer $access_token")

	bulbIDs=$(echo $retrieveLightBulbIDs | jq . | grep light_bulb_id | cut -d \" -f4)
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
	
	result=$(echo $updateLightbulb | jq '.errors != null')

	if [ $result = "true" ]; then
		name=$(echo $updateLightbulb | jq '.data | .name')
		tput setaf 2; echo $name Successful && tput sgr0
	else
		failwithoutexit $(echo $updateLightbulb | jq '.errors')
	fi
}

function sunrise(){
	echo Fade all Lightbulbs On...
	for brightnesslevel in 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1
	do
		updateLightbulb $bulbid true $brightnesslevel
		sleep 10
	done
}

# Check required commands
check_command "jq"

# Get Token
getToken

# Sunrise
sunrise

# Do Something
# updateDevice light_bulbs ###### true
