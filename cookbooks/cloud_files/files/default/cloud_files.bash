#!/bin/bash

# Load the username and password into variables that are used by this
# bash API.
function load_cloud_configs {

	if [ -z "$RACKSPACE_CLOUD_API_USERNAME" ] || [ -z "$RACKSPACE_CLOUD_API_KEY" ]; then

		if [ ! -f ~/.rackspace_cloud ]; then
			echo "Missing .rackspace_cloud config file."
			exit 1
		fi

		export RACKSPACE_CLOUD_API_USERNAME=$(cat ~/.rackspace_cloud | grep "userid" | sed -e "s|.*: \([^ \n\r]*\).*|\1|")
		export RACKSPACE_CLOUD_API_KEY=$(cat ~/.rackspace_cloud | grep "api_key" | sed -e "s|.*: \([^ \n\r]*\).*|\1|")

		if [ -z "$RACKSPACE_CLOUD_API_USERNAME" ] || [ -z "$RACKSPACE_CLOUD_API_KEY" ]; then
			echo "Please define a 'userid' and 'api_key' in ~/.rackspace_cloud"
			exit 1
		fi

	fi

}

# Download a private file from Rackspace Cloud Files using the secure
# X-Storage-Url.
function download_cloud_file {

	if (( $# != 2 )); then
		echo "Failed to download cloud file."
		echo "usage: download_cloud_file <container_url> <output_file>"
		exit 1
	fi

	load_cloud_configs

	local CONTAINER_URL=$1
	local OUTPUT_FILE=$2

	local AUTH_RESPONSE=$(curl -D - \
		-H "X-Auth-Key: $RACKSPACE_CLOUD_API_KEY" \
		-H "X-Auth-User: $RACKSPACE_CLOUD_API_USERNAME" \
		"https://auth.api.rackspacecloud.com/v1.0" 2> /dev/null)

	[[ $? == 0 ]] || { echo "Failed to authenticate."; exit 1; }

	local AUTH_TOKEN=$(echo $AUTH_RESPONSE | \
		sed -e "s|.* X-Auth-Token: \([^ \n\r]*\).*|\1|g")
	local STORAGE_URL=$(echo $AUTH_RESPONSE | \
		sed -e "s|.* X-Storage-Url: \([^ \n\r]*\).*|\1|g")

	curl -s -X GET -H "X-Auth-Token: $AUTH_TOKEN" "$STORAGE_URL/$CONTAINER_URL" -o "$OUTPUT_FILE"

}

# Upload a private file into Rackspace Cloud Files using the secure
# X-Storage-Url.
function upload_cloud_file {

	if (( $# < 2 )); then
		echo "Failed to upload cloud file."
		echo "usage: download_cloud_file <file_to_upload> <container_url>"
		exit 1
	fi

	load_cloud_configs

	local FILE_TO_UPLOAD=$1
	local CONTAINER_URL=$2
	local CONTENT_TYPE=${3:-"application/octet-stream"}

	local AUTH_RESPONSE=$(curl -D - \
		-H "X-Auth-Key: $RACKSPACE_CLOUD_API_KEY" \
		-H "X-Auth-User: $RACKSPACE_CLOUD_API_USERNAME" \
		"https://auth.api.rackspacecloud.com/v1.0" 2> /dev/null)

	[[ $? == 0 ]] || { echo "Failed to authenticate."; exit 1; }

	local AUTH_TOKEN=$(echo $AUTH_RESPONSE | \
		sed -e "s|.* X-Auth-Token: \([^ \n\r]*\).*|\1|g")
	local STORAGE_URL=$(echo $AUTH_RESPONSE | \
		sed -e "s|.* X-Storage-Url: \([^ \n\r]*\).*|\1|g")

	local CONTAINER_NAME=${CONTAINER_URL%/*}
	local FILE_NAME=${CONTAINER_URL#*/}

	# create the container
	curl -s -X PUT -H "X-Auth-Token: $AUTH_TOKEN" "$STORAGE_URL/$CONTAINER_NAME"
	[[ $? == 0 ]] || { echo "Failed to create container."; exit 1; }

	# upload the file
	curl -s -X PUT -T "$FILE_TO_UPLOAD" -H "X-Auth-Token: $AUTH_TOKEN" -H "Content-Type: $CONTENT_TYPE" "$STORAGE_URL/$CONTAINER_NAME/$FILE_NAME"

}

# Return a list of the files in a container. Use .xml, .json or 
# just the normal Cloud Files URL to control the format of the results.
# X-Storage-Url.
function list_cloud_files {

	if (( $# < 1 )); then
		echo "Failed to list container."
		echo "usage: list_cloud_files <container_url>"
		exit 1
	fi

	load_cloud_configs

	local CONTAINER_URL=$1

	local AUTH_RESPONSE=$(curl -D - \
		-H "X-Auth-Key: $RACKSPACE_CLOUD_API_KEY" \
		-H "X-Auth-User: $RACKSPACE_CLOUD_API_USERNAME" \
		"https://auth.api.rackspacecloud.com/v1.0" 2> /dev/null)

	[[ $? == 0 ]] || { echo "Failed to authenticate."; exit 1; }

	local AUTH_TOKEN=$(echo $AUTH_RESPONSE | \
		sed -e "s|.* X-Auth-Token: \([^ \n\r]*\).*|\1|g")
	local STORAGE_URL=$(echo $AUTH_RESPONSE | \
		sed -e "s|.* X-Storage-Url: \([^ \n\r]*\).*|\1|g")

	local CONTAINER_NAME=${CONTAINER_URL%/*}

	# create the container
	DATA=$(curl -s -X GET -H "X-Auth-Token: $AUTH_TOKEN" "$STORAGE_URL/$CONTAINER_NAME")
	[[ $? == 0 ]] || { echo "Failed to list container."; exit 1; }
	echo $DATA

}
