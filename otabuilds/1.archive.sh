#!/bin/bash

# archive project

config=$(dirname $0)/0.configuration.sh
if [ -e $config ]; then
	source $config
else
	echo "No configuration found at '$config', aborting!"
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

# searches the build settings and returns the value for the variable name given in $1
function getSetting {
	echo $(fgrep "$1" $ARCHIVE_PRODUCTS_DIR/settings | cut -d= -f 2 | sed -e 's/^ //')
}

export ARCHIVE=$(safexpand ARCHIVE_PRODUCTS_DIR)/build.xcarchive

rm -rf $(safexpand ARCHIVE_PRODUCTS_DIR)
rm -f $(safexpand IPA_DIR)/*
mkdir $ARCHIVE_PRODUCTS_DIR

# get our build settings
xcodebuild -workspace $(safexpand WORKSPACE) -scheme $(safexpand SCHEME) -showBuildSettings > $ARCHIVE_PRODUCTS_DIR/settings

INFO_PLIST=$(getSetting INFOPLIST_FILE)

BUNDLE_NAME=`/usr/libexec/PlistBuddy -c 'Print :CFBundleDisplayName' "$INFO_PLIST"`
if [[ -z $BUNDLE_NAME ]]; then
	echo "This project does not have a bundle display name. OTA installations will not work without one."
	exit 1
fi

# bump up the build number
if [[ "$AUTO_INCREMENT_BUILD_NUMBER" == "1" ]]; then
	buildNumber=$(/usr/libexec/PlistBuddy -c "Print CFBundleVersion" "${INFO_PLIST}")
	buildNumber=$(($buildNumber + 1))
	echo "Setting build number to $buildNumber"
	/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $buildNumber" "${INFO_PLIST}"
fi

# this creates a file $ARCHIVE.xcarchive
xcodebuild -workspace $(safexpand WORKSPACE)  -scheme $(safexpand SCHEME) -archivePath $ARCHIVE clean archive

# get the bundle ID and version info from the archive
BUNDLE_ID=`/usr/libexec/PlistBuddy -c "print ApplicationProperties:CFBundleIdentifier" $ARCHIVE/Info.plist`
BUNDLE_BUILD=`/usr/libexec/PlistBuddy -c 'Print ApplicationProperties:CFBundleVersion' "$ARCHIVE/Info.plist"`
BUNDLE_VERSION=`/usr/libexec/PlistBuddy -c 'Print ApplicationProperties:CFBundleShortVersionString' "$ARCHIVE/Info.plist"`
VERSION="$BUNDLE_VERSION.$BUNDLE_BUILD"

# get the provisioning profile named
# old way:
# security cms -D -i $ARCHIVE/Products/Applications/*.app/embedded.mobileprovision > $ARCHIVE_PRODUCTS_DIR/provisioning.plist 2>/dev/null
# PROVISIONING_PROFILE_NAME=`/usr/libexec/PlistBuddy -c "print Name" $ARCHIVE_PRODUCTS_DIR/provisioning.plist`
# new way:
PROVISIONING_PROFILE_NAME=$(getSetting PROVISIONING_PROFILE_SPECIFIER)

# get the team ID
# old way
# TEAM_ID=`/usr/libexec/PlistBuddy -c 'print TeamIdentifier:0' $ARCHIVE_PRODUCTS_DIR/provisioning.plist`

# export the archive to an IPA
#
# but first need to create the export options plist
CODE_SIGN_IDENTITY=$(getSetting CODE_SIGN_IDENTITY)
TEAM_ID=$(getSetting DEVELOPMENT_TEAM)

cat - > $ARCHIVE_PRODUCTS_DIR/exportOptions.plist <<ExportOptionsEnd
<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>compileBitcode</key>
	<false/>
	<key>method</key>
	<string>$SIGNING_METHOD</string>
	<key>provisioningProfiles</key>
	<dict>
		<key>$BUNDLE_ID</key>
		<string>$PROVISIONING_PROFILE_NAME</string>
	</dict>
	<key>signingCertificate</key>
	<string>$CODE_SIGN_IDENTITY</string>
	<key>signingStyle</key>
	<string>manual</string>
	<key>stripSwiftSymbols</key>
	<true/>
	<key>teamID</key>
	<string>$TEAM_ID</string>
	<key>thinning</key>
	<string>&lt;none&gt;</string>
</dict>
</plist>
ExportOptionsEnd

xcodebuild -exportArchive -archivePath $ARCHIVE -exportPath $IPA_DIR -exportOptionsPlist $ARCHIVE_PRODUCTS_DIR/exportOptions.plist 

# rename the output IPA
mv $IPA_DIR/$SCHEME.ipa $IPA_DIR/$SCHEME-$VERSION-.ipa

# remove the other garbage export put in there
rm $IPA_DIR/*.plist $IPA_DIR/*.log
