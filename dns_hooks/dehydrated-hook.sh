#!/usr/bin/env bash

# based on https://github.com/lukas2511/dehydrated/wiki/example-dns-01-nsupdate-script

set -e
set -u
set -o pipefail

# the api location without trailing /
APIURL="https://lxd-manager.tld"
# the id of the updateable object, found on the /api/dynamicentry/ list overview
UPDATEID=1
# the token of one of the owners
TOKEN="123987acf9871092837918279381723"


case "$1" in
	"deploy_challenge")
		echo ""
		echo "Adding the following to the zone definition of ${2}:"
		echo "_acme-challenge.${2}. IN TXT \"${4}\""
		echo ""
		curl -H "Authorization: Token ${TOKEN}" -X PUT -H "Content-Type: application/json" -d "{\"value\":\"${4}\"}"  ${APIURL}/api/dynamicentry/${UPDATEID}/
	;;
	"clean_challenge")
		echo ""
		echo "Removeing the following from the zone definition of ${2}:"
		echo "_acme-challenge.${2}. IN TXT \"${4}\""
		echo ""
		curl -H "Authorization: Token ${TOKEN}" -X PUT -H "Content-Type: application/json" -d "{\"value\":\"\"}"  ${APIURL}/api/dynamicentry/${UPDATEID}/
	;;
	"sync_cert")
		# do nothing for now
	;;
	"deploy_cert")
		# do nothing for now
	;;
	"unchanged_cert")
		# do nothing for now
	;;
	"exit_hook")
		echo "${2:-}"
	;;
	*)
		echo "Unknown hook \"${1}\""
	;;
esac

exit 0
