# configuration info

# set this to 1 if you want the scripts to bump up the build number for you. Set to 0 if you want to do it yourself
export AUTO_INCREMENT_BUILD_NUMBER=1

# which scheme to build. This will specify the target and configuration to use
export SCHEME=Carnival

# the workspace to use
export WORKSPACE=Carnival.xcworkspace

# the path to send the OTA bits (using AWS cli)
export S3_OTA_URL=s3://lbs-prod/redimedi/CarnivalBuilds
# the URL the bits will be referenced from browser
export HTTPS_OTA_URL=https://lbs-prod.s3.amazonaws.com/redimedi/CarnivalBuilds
# location of app icon, relative from project root dir
export APP_ICON=Carnival/Resources/Assets.xcassets/AppIcon.appiconset/Icon-60@2x.png

#########################################################################################
# advanced configurations. You probably don't need to change these, but can if you want
export ARCHIVE_PRODUCTS_DIR=build_temp
export IPA_DIR=IPA

# method can be one of app-store, ad-hoc, package, enterprise, development, and developer-id 
export SIGNING_METHOD=enterprise

# OTA bits destination dir
export OTA_DIR=OTA

