#!/bin/bash



# Functions used in the script
# ------------------------------------------------------------------------------

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

# Function to print any error to stderr
function print_error {	# $1=error_message $2=print_usage $3=exit_code
	echo "" >&2
	echo "ERROR: $1" >&2
	if [ $2 -ne 0 ]; then
		print_usage
	fi
	if [ $3 -ne 0 ]; then
		exit $3
	fi
}

function getOtherBuilds { # $1=URL of Builds/version dir $2=skip this release
	# need to get the root
	root=$(dirname $1)
	
	# get existing builds so we can preserve those
	builds=$(aws s3 ls $S3_OTA_URL/ | fgrep PRE | sed -e s"/^[ \t]*PRE //" -e s":/$::" | sort -n -r)
	for build in $builds; do
		# get the date this build was made
		datetime=$(aws s3 ls $S3_OTA_URL/$build/ | fgrep install.plist | cut -d' ' -f1,2)
		if [[ -z "$datetime" ]]; then
			# skip this, no install.plist in there
			continue
		fi
		
		# is it a release we already took care of in the initial HTML?
		if [[ $build == $2 ]]; then continue; fi
		
		cat - <<END
		<tr><td>
			<img src=$build/icon.png style="width:100px;height:100px;" class="rounded-corners">
		</td></tr>
		<tr><td>
			<a class="btn" href="itms-services://?action=download-manifest&url=$root/$build/install.plist">Install</a>
		</td></tr>
		<tr><td>
			Version: $build <br> Updated: $datetime
		</td></tr>
		<tr><tr/></tr>
END
	done
}

# Function to create an over-the-air installation HTML file
function create_install_html {	# $1=url_path $2=app_name $3=output_file $4=icon url
	# Create the install HTML file
	cat - > "$3" <<InstallHtmlDelimiter
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
	<head>
		<meta name="viewport" content="width=device-width, user-scalable=yes">
		<title>$2 Over-the-air Installation</title>
		<style type="text/css">
		  	body{color:#000000;font:14px Arial, Helvetica, sans-serif; background-color: #FFFFFF;}
			.btn {
			  background: #3498db;
			  background-image: -webkit-linear-gradient(top, #3498db, #2980b9);
			  background-image: -moz-linear-gradient(top, #3498db, #2980b9);
			  background-image: -ms-linear-gradient(top, #3498db, #2980b9);
			  background-image: -o-linear-gradient(top, #3498db, #2980b9);
			  background-image: linear-gradient(to bottom, #3498db, #2980b9);
			  -webkit-border-radius: 28;
			  -moz-border-radius: 28;
			  border-radius: 28px;
			  font-family: Arial;
			  color: #ffffff;
			  font-size: 20px;
			  padding: 10px 20px 10px 20px;
			  text-decoration: none;
			}
			img.rounded-corners {
				border-radius: 20px;
			}
			td {
				text-align: center;
			}
			table {
				border-spacing: 20px;
			}
		</style>
    </head>
	<body>
		<table style="width:100%">
		<tr><td>
			<img src=$4 style="width:100px;height:100px;" class="rounded-corners">
		</td></tr>
		<tr><td>
			<a class="btn" href="itms-services://?action=download-manifest&url=$1/install.plist">Install</a>
		</td></tr>
		<tr><td>
			$VERSION_INFO
		</td></tr>
		<tr><tr/></tr>
		$(getOtherBuilds "$1" $(dirname $4))
		</table>
	</body>
</html>
InstallHtmlDelimiter
}

# Function to create an over-the-air installation manifest (plist file)
function create_install_plist {	# $1=url_path $2=ipa_filename $3=bundle_id $4=app_version $5=display_name $6=output_file
	# Create the install manifest
	cat - > "$6" <<InstallPlistDelimiter
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
	<dict>
		<key>items</key>
		<array>
			<dict>
				<key>assets</key>
				<array>
					<dict>
						<key>kind</key>
						<string>software-package</string>
						<key>url</key>
						<string>$1/$2</string>
					</dict>
				</array>
				<key>metadata</key>
				<dict>
					<key>bundle-identifier</key>
					<string>$3</string>
					<key>bundle-version</key>
					<string>$4</string>
					<key>kind</key>
					<string>software</string>
					<key>title</key>
					<string>$5</string>
				</dict>
			</dict>
		</array>
	</dict>
</plist>
InstallPlistDelimiter
}

# Start of script
# ------------------------------------------------------------------------------

# Init variables
IPA=$(safexpand IPA_DIR)
INPUT_IPA=`ls $IPA/*.ipa`
OUTPUT_DIR=$(safexpand OTA_DIR)
INSTALL_URL="$(safexpand HTTPS_OTA_URL)"
VERSION_INFO=""

rm -rf $OUTPUT_DIR
mkdir -p $OUTPUT_DIR

# Create a clean temporary directory
TEMP_DIR="tmp"
rm -rf $TEMP_DIR
if [ $? -ne 0 ]; then print_error "Couldn't remove old temporary directory at $TEMP_DIR" 0 1; fi
mkdir $TEMP_DIR
if [ $? -ne 0 ]; then print_error "Couldn't create temporary directory at $TEMP_DIR" 0 1; fi
echo "Using temporary directory: $TEMP_DIR"

# unzip the IPA fila
echo "Unzipping IPA file..."
unzip $INPUT_IPA -d $TEMP_DIR 1>/dev/null
if [ $? -ne 0 ]; then print_error "Failed to unzip input IPA file: $INPUT_IPA" 0 1; fi

# Get the app bundle name with path
PAYLOAD_DIR="$TEMP_DIR/Payload"
APP_BUNDLE="$PAYLOAD_DIR/`ls $PAYLOAD_DIR/`"

# Get the info.plist file and bundle identifier
INFO_PLIST="$APP_BUNDLE/Info.plist"
BUNDLE_IDENTIFIER=`/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$INFO_PLIST"`
BUNDLE_BUILD=`/usr/libexec/PlistBuddy -c 'Print :CFBundleVersion' "$INFO_PLIST"`
BUNDLE_VERSION=`/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$INFO_PLIST"`
BUNDLE_NAME=`/usr/libexec/PlistBuddy -c 'Print :CFBundleDisplayName' "$INFO_PLIST"`
echo "App Bundle: $APP_BUNDLE ($BUNDLE_IDENTIFIER v$BUNDLE_VERSION)"
IPA_FILENAME=`basename "$INPUT_IPA"`

# Get the version information
MOD_VERS="$BUNDLE_VERSION.$BUNDLE_BUILD"
MOD_DATE=`stat -f %m $INPUT_IPA`
MOD_DATE=`date -r $MOD_DATE`
VERSION_INFO="Version: $MOD_VERS <br> Updated: $MOD_DATE"

# update the install URL to include the version, which is where the plist and bits will go
INSTALL_VERSION_URL=$INSTALL_URL/$MOD_VERS

# Create the installation html file
echo "Creating install files..."
# Create install HTML file: $1=url_path $2=app_name $3=output_file
create_install_html "$INSTALL_VERSION_URL" "$BUNDLE_NAME" "$OUTPUT_DIR/install.html" $MOD_VERS/icon.png

# Create install manifest: $1=url_path $2=ipa_filename $3=bundle_id $4=app_version $5=display_name $6=output_file
create_install_plist "$INSTALL_VERSION_URL" "$IPA_FILENAME" "$BUNDLE_IDENTIFIER" "$BUNDLE_VERSION" "$BUNDLE_NAME" "$OUTPUT_DIR/install.plist"

# Copy the IPA file 
echo "Copying $INPUT_IPA to $OUTPUT_DIR"
cp "$INPUT_IPA" "$OUTPUT_DIR/"

# Copy the app icon
echo "Copying $APP_ICON to $OUTPUT_DIR"
cp $(safexpand APP_ICON) "$OUTPUT_DIR/icon.png"

# Cleanup...
echo "Cleaning up..."
rm -rf "$TEMP_DIR"
