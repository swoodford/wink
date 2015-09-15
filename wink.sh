#!/usr/bin/env bash
# This script uses the Wink API to control IOT enabled devices
# Requires jq, curl

# Set credentials
. ./set-credentials.sh

# Device menu
. ./menu.sh

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

function retrieveAirConditioners(){
	retrieveAirConditioners=$(curl -s "$APIURL"/users/me/air_conditioners \
		-H "Authorization: Bearer $access_token")

	# echo $retrieveAllDevices | jq .
}

function getRobots(){
	getRobots=$(curl -s "$APIURL"/users/me/robots \
		-H "Authorization: Bearer $access_token")

	echo $getRobots | jq .
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

function lightsOn(){
	echo Turn all Lightbulbs On...
	for bulbid in $bulbIDs
	do
		updateLightbulb $bulbid true 1
	done
}

function lightsOff(){
	echo Turn all Lightbulbs Off...
	for bulbid in $bulbIDs
	do
		updateLightbulb $bulbid false 0
	done
}

function fadeLightsOn(){
	echo Fade all Lightbulbs On...
	for brightnesslevel in 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1
	do
		for bulbid in $bulbIDs
		do
			updateLightbulb $bulbid true $brightnesslevel
			sleep 1
		done
	done
}

function fadeLightsOff(){
	echo Fade all Lightbulbs Off...
	for brightnesslevel in 1 0.9 0.8 0.7 0.6 0.5 0.4 0.3 0.2 0.1 0
	do
		for bulbid in $bulbIDs
		do
			updateLightbulb $bulbid true $brightnesslevel
			sleep 1
		done
	done

	for bulbid in $bulbIDs
	do
		updateLightbulb $bulbid false 0
	done
}

function retrieveACIDs(){
	retrieveACIDs=$(curl -s "$APIURL"/users/me/air_conditioners \
		-H "Authorization: Bearer $access_token")

	ACIDs=$(echo $retrieveACIDs | jq . | grep air_conditioner_id | cut -d \" -f4)
}

function updateAC(){
	updateAC=$(curl -sX PUT "$APIURL"/air_conditioners/"$1" \
		-H "Authorization: Bearer $access_token" \
		-H "Content-Type: application/json" \
		--data-binary '{
			"desired_state": {
				"powered": "'"$2"'",
				"fan_speed": "'"$3"'",
				"mode": "'"$4"'",
				"max_set_point": "'"$5"'"
			}
		}')
	result=$(echo $updateAC | jq '.errors != null')

	if [ $result = "true" ]; then
		name=$(echo $updateAC | jq '.data | .name')
		tput setaf 2; echo $name Successful && tput sgr0
	else
		failwithoutexit $(echo $updateAC | jq '.errors')
	fi
}

function updateACmode(){
	updateACmode=$(curl -sX PUT "$APIURL"/air_conditioners/"$1" \
		-H "Authorization: Bearer $access_token" \
		-H "Content-Type: application/json" \
		--data-binary '{
			"desired_state": {
				"powered": "'"$2"'",
				"mode": "'"$3"'"
			}
		}')
	
	result=$(echo $updateACmode | jq '.errors != null')

	if [ $result = "true" ]; then
		name=$(echo $updateACmode | jq '.data | .name')
		tput setaf 2; echo $name Successful && tput sgr0
	else
		failwithoutexit $(echo $updateACmode | jq '.errors')
	fi
}

function updateACtemp(){
	updateACtemp=$(curl -sX PUT "$APIURL"/air_conditioners/"$1" \
		-H "Authorization: Bearer $access_token" \
		-H "Content-Type: application/json" \
		--data-binary '{
			"desired_state": {
				"powered": "'"$2"'",
				"max_set_point": "'"$3"'"
			}
		}')
	
	result=$(echo $updateACtemp | jq '.errors != null')

	if [ $result = "true" ]; then
		name=$(echo $updateACtemp | jq '.data | .name')
		tput setaf 2; echo $name Successful && tput sgr0
	else
		failwithoutexit $(echo $updateACtemp | jq '.errors')
	fi
}

function updateACfan(){
	updateACfan=$(curl -sX PUT "$APIURL"/air_conditioners/"$1" \
		-H "Authorization: Bearer $access_token" \
		-H "Content-Type: application/json" \
		--data-binary '{
			"desired_state": {
				"powered": "'"$2"'",
				"fan_speed": "'"$3"'"
			}
		}')
	
	result=$(echo $updateACfan | jq '.errors != null')

	if [ $result = "true" ]; then
		name=$(echo $updateACfan | jq '.data | .name')
		tput setaf 2; echo $name Successful && tput sgr0
	else
		failwithoutexit $(echo $updateACfan | jq '.errors')
	fi
}

function updateACs(){
	echo Set Air Conditioners...
	ACTempC=$(echo "scale=2;(5/9)*($3-32)"|bc)
	for ACid in $ACIDs
	do
		updateAC $ACid true $1 $2 $ACTempC
	done
}

function ACOn(){
	echo Turn all Air Conditioners On...
	for ACid in $ACIDs
	do
		updateAC $ACid true
	done
}

function ACOff(){
	echo Turn all Air Conditioners Off...
	for ACid in $ACIDs
	do
		updateAC $ACid false
	done
}

function ACMode(){
	echo Set Air Conditioners Mode...
	for ACid in $ACIDs
	do
		updateACmode $ACid true $1
	done
}

function ACTemp(){
	echo Set Air Conditioners Temp...
	ACTempC=$(echo "scale=2;(5/9)*($1-32)"|bc)
	for ACid in $ACIDs
	do
		updateACtemp $ACid true $ACTempC
	done
}

function ACFan(){
	echo Set Air Conditioners Fan...
	for ACid in $ACIDs
	do
		updateACfan $ACid true $1
	done
}

# Check required commands
check_command "jq"
check_command "curl"

# Get Token
getToken

# List all your devices
# retrieveAllDevices
# retrieveAirConditioners

# Do Something - Turn on a lightbulb
# updateLightbulb light_bulbs {your_lightbulb_id_000000} true 1.00

# retrieveLightBulbIDs
# echo $bulbIDs

# fadeLightsOff

# Loop the Menu
while :
do
	# Call the menu
	deviceMenu
done
