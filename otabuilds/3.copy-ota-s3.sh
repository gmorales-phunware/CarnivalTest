#!/bin/bash
#
# this will copy OTA output files to S3

if [ -z `which aws` ]; then
	echo "You need to install the AWS command line tool. See Confluence instructions"
	exit
fi

config=$(dirname $0)/0.configuration.sh
if [ -e $config ]; then
	source $config
else
	echo "No configuration found, aborting!"
	exit 1
fi

function safexpand {
	eval value=\$$1
	if [ -z $value ]; then
		echo "Configuration variable $1 not set!"
		exit 1
	fi
	
	echo $value	
}	

# main
SRC=$(safexpand OTA_DIR)
# the stupid trailing slash is quite important
DEST="$(safexpand S3_OTA_URL)/"

VERSION=$(ls $SRC/*.ipa | cut -d- -f 2)
DEST_VERSION=$DEST$VERSION/
ICON=$(safexpand APP_ICON)

aws s3 cp $SRC/install.html $DEST --acl public-read
aws s3 cp $SRC/install.plist $DEST_VERSION --acl public-read
aws s3 cp $SRC/*.ipa $DEST_VERSION --acl public-read
aws s3 cp $ICON ${DEST_VERSION}icon.png --acl public-read

echo "Build can be accessed from $HTTPS_OTA_URL/install.html"
