#!/bin/sh
# from http://moderntoil.com/?p=839   
#
# WeMo Control Script
# 
# rich@netmagi.com
#
# Usage: ./wemo_control IP_ADDRESS ON/OFF/GETSTATE/GETSIGNALSTRENGTH/GETFRIENDLYNAME
#
#
# nsultana July 2019: extended with PORT parameter and GETPOWER command

IP=$1
COMMAND=$3
PORT=$2

if [ "$1" = "" ]
	then
		echo "Usage: ./wemo_control IP_ADDRESS PORT[4915{2,3,4}] ON/OFF/GETSTATE/GETSIGNALSTRENGTH/GETFRIENDLYNAME/GETPOWER"
    exit 1
else
	if [ "$COMMAND" = "GETSTATE" ]

		then 

			curl -0 -A '' -X POST -H 'Accept: ' -H 'Content-type: text/xml; charset="utf-8"' -H "SOAPACTION: \"urn:Belkin:service:basicevent:1#GetBinaryState\"" --data '<?xml version="1.0" encoding="utf-8"?><s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"><s:Body><u:GetBinaryState xmlns:u="urn:Belkin:service:basicevent:1"><BinaryState>1</BinaryState></u:GetBinaryState></s:Body></s:Envelope>' -s http://$IP:$PORT/upnp/control/basicevent1 | 
grep "<BinaryState"  | cut -d">" -f2 | cut -d "<" -f1 | sed 's/0/OFF/g' | sed 's/1/ON/g' 

	elif [ "$2" = "ON" ]

		then

			curl -0 -A '' -X POST -H 'Accept: ' -H 'Content-type: text/xml; charset="utf-8"' -H "SOAPACTION: \"urn:Belkin:service:basicevent:1#SetBinaryState\"" --data '<?xml version="1.0" encoding="utf-8"?><s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"><s:Body><u:SetBinaryState xmlns:u="urn:Belkin:service:basicevent:1"><BinaryState>1</BinaryState></u:SetBinaryState></s:Body></s:Envelope>' -s http://$IP:$PORT/upnp/control/basicevent1 |
grep "<BinaryState"  | cut -d">" -f2 | cut -d "<" -f1

	elif [ "$COMMAND" = "OFF" ]

		then

			curl -0 -A '' -X POST -H 'Accept: ' -H 'Content-type: text/xml; charset="utf-8"' -H "SOAPACTION: \"urn:Belkin:service:basicevent:1#SetBinaryState\"" --data '<?xml version="1.0" encoding="utf-8"?><s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"><s:Body><u:SetBinaryState xmlns:u="urn:Belkin:service:basicevent:1"><BinaryState>0</BinaryState></u:SetBinaryState></s:Body></s:Envelope>' -s http://$IP:$PORT/upnp/control/basicevent1 |
grep "<BinaryState"  | cut -d">" -f2 | cut -d "<" -f1

	elif [ "$COMMAND" = "GETSIGNALSTRENGTH" ]

               then

                        curl -0 -A '' -X POST -H 'Accept: ' -H 'Content-type: text/xml; charset="utf-8"' -H "SOAPACTION: \"urn:Belkin:service:basicevent:1#GetSignalStrength\"" --data '<?xml version="1.0" encoding="utf-8"?><s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"><s:Body><u:GetSignalStrength xmlns:u="urn:Belkin:service:basicevent:1"><GetSignalStrength>0</GetSignalStrength></u:GetSignalStrength></s:Body></s:Envelope>' -s http://$IP:$PORT/upnp/control/basicevent1 |
grep "<SignalStrength"  | cut -d">" -f2 | cut -d "<" -f1

	elif [ "$COMMAND" = "GETFRIENDLYNAME" ]

                then

			curl -0 -A '' -X POST -H 'Accept: ' -H 'Content-type: text/xml; charset="utf-8"' -H "SOAPACTION: \"urn:Belkin:service:basicevent:1#ChangeFriendlyName\"" --data '<?xml version="1.0" encoding="utf-8"?><s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"><s:Body><u:ChangeFriendlyName xmlns:u="urn:Belkin:service:basicevent:1"><FriendlyName>Pool Filter</FriendlyName></u:ChangeFriendlyName></s:Body></s:Envelope>' -s http://$IP:$PORT/upnp/control/basicevent1 | \
grep "<FriendlyName"  | cut -d">" -f2 | cut -d "<" -f1
           
elif [ "$COMMAND" = "GETPOWER" ]
then
			curl -0 -A '' -X POST -H 'Accept: ' -H 'Content-type: text/xml; charset="utf-8"' -H "SOAPACTION: \"urn:Belkin:service:insight:1#GetInsightParams\"" --data '<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"><s:Body><u:GetInsightParams xmlns:u="urn:Belkin:service:insight:1"/></s:Body></s:Envelope>' -s http://$IP:$PORT/upnp/control/insight1 | \
				grep '<InsightParams>' | cut -d">" -f2|cut -d"|" -f8 

	else
		echo "COMMAND NOT RECOGNIZED"
		echo ""
		echo "Usage: ./wemo_control IP_ADDRESS PORT ON/OFF/GETSTATE/GETSIGNALSTRENGTH/GETFRIENDLYNAME"
		echo ""
	fi
fi
