#!/usr/bin/env bash

function deviceMenu
{
	echo
	echo =================
	echo Wink Device Menu:
	echo =================
	echo 1. Lightbulbs
	echo 2. Air Conditioners
	echo 3. Egg Minder
	echo
	echo =================
	echo Quick Shortcuts:
	echo =================
	echo 4. Leave The House
	echo 5. Come Home
	echo 6. Get Average Temperature
	echo
	echo Q. Quit
    echo
	read -r -p "Select Menu #: " menuSelection

    case $menuSelection in
    	1)
			echo
			echo ================
			echo Lightbulbs Menu:
			echo ================
			echo 1. Turn all Lightbulbs On
			echo 2. Turn all Lightbulbs Off
			echo 3. Fade all Lightbulbs On
			echo 4. Fade all Lightbulbs Off
			echo Q. Quit
			echo
			read -r -p "Select Operation #: " bulbSelection
			retrieveLightBulbIDs

			case $bulbSelection in
				1)
					lightsOn
					pause
				;;

				2)
					lightsOff
					pause
				;;

				3)
					fadeLightsOn
					pause
				;;

				4)
					fadeLightsOff
					pause
				;;

				q)
					echo "Canceled"
				;;

				Q)
					echo "Canceled"
				;;

				*)
					echo "Invalid selection, exiting..."
					echo ""
				;;
			esac
		;;

		2)
			echo
			echo ======================
			echo Air Conditioners Menu:
			echo ======================
			echo 1. Turn all On
			echo 2. Turn all Off
			echo 3. Set Mode
			echo 4. Set Temp
			echo 5. Set Fan Speed
			echo 6. Set to Eco
			echo 7. Set to Max Cool
			echo Q. Quit
			echo
			read -r -p "Select Operation #: " ACselection
			retrieveACIDs

			case $ACselection in
				1)
					ACOn
					pause
				;;

				2)
					ACOff
					pause
				;;

				3)
					echo
					echo ======================
					echo Air Conditioners Mode:
					echo ======================
					echo 1. Cool
					echo 2. Fan
					echo 3. Eco
					echo Q. Quit
					echo
					read -r -p "Select Mode #: " ACmode

					case $ACmode in
						1)
							ACMode cool_only
							pause
						;;

						2)
							ACMode fan_only
							pause
						;;

						3)
							ACMode auto_eco
							pause
						;;

						q)
							echo "Canceled"
						;;

						Q)
							echo "Canceled"
						;;

						*)
							echo "Invalid selection, exiting..."
							echo ""
						;;
					esac
				;;

				4)
					echo
					echo ======================
					echo Air Conditioners Temp:
					echo ======================
					echo 1. 66 $'\xc2\xb0'F
					echo 2. 73 $'\xc2\xb0'F
					echo 3. Enter Temp
					echo Q. Quit
					echo
					read -r -p "Select Temp #: " ACtemp

					case $ACtemp in
						1)
							ACTemp 64
							pause
						;;

						2)
							ACTemp 73
							pause
						;;

						3)
							read -r -p "Enter Desired Temp: " ACmanualTemp
							ACTemp $ACmanualTemp
							pause
						;;

						q)
							echo "Canceled"
						;;

						Q)
							echo "Canceled"
						;;

						*)
							echo "Invalid selection, exiting..."
							echo ""
						;;
					esac
				;;

				5)
					echo
					echo ======================
					echo Air Conditioners Fan:
					echo ======================
					echo 1. Quiet
					echo 2. Low
					echo 3. Med
					echo 4. High
					echo Q. Quit
					echo
					read -r -p "Select Fan Speed #: " ACfan

					case $ACfan in
						1)
							ACFan .2
							pause
						;;

						2)
							ACFan .33
							pause
						;;

						3)
							ACFan .66
							pause
						;;

						4)
							ACFan 1.0
							pause
						;;

						q)
							echo "Canceled"
						;;

						Q)
							echo "Canceled"
						;;

						*)
							echo "Invalid selection, exiting..."
							echo ""
						;;
					esac
				;;

				6)
					ACMode auto_eco
					ACTemp 73
					ACFan .33
					pause
				;;

				7)
					ACMode cool_only
					ACTemp 64
					ACFan 1.0
					pause
				;;

				q)
					echo "Canceled"
				;;

				Q)
					echo "Canceled"
				;;

				*)
					echo "Invalid selection, exiting..."
					echo ""
				;;
			esac
		;;

		3)
			echo
			echo Egg Minder
			echo "This doesn't do anything yet."
		;;

		4)
			echo
			echo "Leave The House (AC Eco, Lights Off)"
			retrieveACIDs
			updateACs .33 auto_eco 73
			# ACMode auto_eco
			# ACTemp 73
			# ACFan .33
			retrieveLightBulbIDs
			lightsOff
			pause
		;;

		5)
			echo
			echo "Come Home (AC Max Cool, Lights On)"
			retrieveACIDs
			updateACs 1.0 cool_only 64
			# ACMode cool_only
			# ACTemp 64
			# ACFan 1.0
			retrieveLightBulbIDs
			lightsOn
			pause
		;;

		6)
			retrieveAirConditioners
			GetCurrentAverageTemp
			echo
			echo Current Average Temp: $tempF $'\xc2\xb0'F
			pause
		;;

		q)
			echo "Bye!"
			exit 0
		;;

		Q)
			echo "Bye!"
			exit 0
		;;

		*)
			echo "Invalid selection, exiting..."
			echo ""
		;;
	esac
}

