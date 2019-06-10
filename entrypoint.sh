#!/bin/bash
cd /home/container

# Output Current Java Version
java -version

# Make internal Docker IP address available to processes.
export INTERNAL_IP=`ip route get 1 | awk '{print $NF;exit}'`

# Update the server
if [ -n "${DL_PATH}" ]; then
	echo -e "using supplied download url"
	DOWNLOAD_URL=`eval echo $(echo ${DL_PATH} | sed -e 's/{{/${/g' -e 's/}}/}/g')`
else
	VERSIONS=`curl -s https://papermc.io/api/v1/paper`
	LATEST_PAPER_VERSION=$(echo $VERSIONS | grep -Po '(?<=\"versions\"\:\[\")(.*?)(?=\")')
	if [[ $VERSIONS == *"\"${MINECRAFT_VERSION}\""* ]]; then
		echo -e "Version is valid. Using version ${MINECRAFT_VERSION}"
	else
		echo -e "Using the latest paper version"
		MINECRAFT_VERSION=${LATEST_PAPER_VERSION}
	fi
	
	BUILDS=`curl -s https://papermc.io/api/v1/paper/${MINECRAFT_VERSION}`
	LATEST_PAPER_BUILD=$(echo $BUILDS | grep -Po '(?<=\"latest\"\:\")(.*?)(?=\")')
	if [ $BUILDS == *"\"${BUILD_NUMBER}\""* ] || [ ${BUILD_NUMBER} == "latest" ]; then
		echo -e "Build is valid. Using version ${BUILD_NUMBER}"
	else
		echo -e "Using the latest paper build"
		BUILD_NUMBER=${LATEST_PAPER_BUILD}
	fi

	echo "Version being downloaded"
	echo -e "MC Version: ${MINECRAFT_VERSION}"
	echo -e "Build: ${BUILD_NUMBER}"
	DOWNLOAD_URL=https://papermc.io/api/v1/paper/${MINECRAFT_VERSION}/${BUILD_NUMBER}/download
fi
echo -e "Downloading..."
curl -s -o ${SERVER_JARFILE} ${DOWNLOAD_URL}

# Replace Startup Variables
MODIFIED_STARTUP=`eval echo $(echo ${STARTUP} | sed -e 's/{{/${/g' -e 's/}}/}/g')`
echo ":/home/container$ ${MODIFIED_STARTUP}"

# Run the Server
eval ${MODIFIED_STARTUP}
