#!/usr/bin/env bash

# Set Required Variables

client_id="consumer_key_goes_here"
client_secret="consumer_secret_goes_here"
username="user@example.com"
password="password_goes_here"
APIURL="https://winkapi.quirky.com/"

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
	# pause

	access_token=$(echo $getToken | jq '.access_token' | cut -d '"' -f 2)
	if [ "$access_token" = "null" ]; then
		fail "Unable to get valid access token."
	fi
	# refresh_token=$(echo $getToken | jq '.refresh_token' | cut -d '"' -f 2)
	# echo $refresh_token
}
