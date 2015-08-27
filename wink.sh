#!/usr/bin/env bash
# This script uses the Wink API to control IOT enabled devices

# Set Required Variables
client_id="consumer_key_goes_here"
client_secret="consumer_secret_goes_here"
username="user@example.com"
password="password_goes_here"
APIURL="https://winkapi.quirky.com/"

# Functions
function check_command {
	type -P $1 &>/dev/null || fail "Unable to find $1, please install it and run this script again."
}

function fail(){
	tput setaf 1; echo "Failure: $*" && tput sgr0
	exit 1
}

function getToken(){
	if [ "$client_id" = "consumer_key_goes_here" ]; then
		fail "You have not setup your credentials in the script!"
	else
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
	fi

	# echo $getToken | jq .

	access_token=$(echo $getToken | jq '.access_token' | cut -d '"' -f 2)
	if [ "$access_token" = "null" ]; then
		fail "Unable to get valid access token."
	fi
	# refresh_token=$(echo $getToken | jq '.refresh_token' | cut -d '"' -f 2)
	# echo $refresh_token
}

function linkedServices(){
	linkedServices=$(curl -s "$APIURL"/users/me/linked_services \
		-H "Authorization: Bearer $access_token")

	echo $linkedServices | jq .
}

function retrieveAllDevices(){
	retrieveAllDevices=$(curl -s "$APIURL"/users/me/wink_devices \
		-H "Authorization: Bearer $access_token")

	echo $retrieveAllDevices | jq .
}

function retrieveLightBulbIDs(){
	retrieveLightBulbIDs=$(curl -s "$APIURL"/users/me/light_bulbs \
		-H "Authorization: Bearer $access_token")

	bulbIDs=$(echo $retrieveLightBulbIDs | jq . | grep light_bulb_id | cut -d \" -f4)
}

function getRobots(){
	getRobots=$(curl -s "$APIURL"/users/me/robots \
		-H "Authorization: Bearer $access_token")

	echo $getRobots | jq .
}

# Turn a light bulb on or off and set brightness level
function updateDevice(){
	updateDevice=$(curl -sX PUT "$APIURL"/"$1"/"$2" \
		-H "Authorization: Bearer $access_token" \
		-H "Content-Type: application/json" \
		--data-binary '{
			"desired_state": {
				"powered": "'"$3"'",
				"brightness": "'"$4"'"
			}
		}')

	echo $updateDevice | jq .
}

function lightsOn(){
	for bulbid in $bulbIDs
	do
		updateDevice light_bulbs $bulbid true 1
	done
}

function lightsOff(){
	for bulbid in $bulbIDs
	do
		updateDevice light_bulbs $bulbid false 0
	done
}


function fadeLightsOn(){
	for brightnesslevel in 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1
	do
		for bulbid in $bulbIDs
		do
			updateDevice light_bulbs $bulbid true $brightnesslevel
			sleep 1
		done
	done
}

function fadeLightsOff(){
	for brightnesslevel in 1 0.9 0.8 0.7 0.6 0.5 0.4 0.3 0.2 0.1 0
	do
		for bulbid in $bulbIDs
		do
			updateDevice light_bulbs $bulbid true $brightnesslevel
			sleep 1
		done
	done
}

# Check required commands
check_command "jq"

# Get Token
getToken

# List all your devices
# retrieveAllDevices

# Do Something - Turn on a lightbulb
# updateDevice light_bulbs {your_lightbulb_id_000000} true 1.00

retrieveLightBulbIDs

fadeLightsOn
