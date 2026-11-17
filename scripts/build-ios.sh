#!/bin/bash
# Builds an unsigned Hive.ipa on a Mac (used by the GitHub workflow, or run it yourself on a Mac).
set -e
npm install
npx cap add ios
npx @capacitor/assets generate --ios
npx cap sync ios
# the profile photo picker needs these two permission texts
P=ios/App/App/Info.plist
/usr/libexec/PlistBuddy -c "Add :NSPhotoLibraryUsageDescription string Choose a photo for your profile." "$P" || true
/usr/libexec/PlistBuddy -c "Add :NSCameraUsageDescription string Take a photo for your profile." "$P" || true
if [ -d ios/App/App.xcworkspace ]; then TARGET="-workspace ios/App/App.xcworkspace"; else TARGET="-project ios/App/App.xcodeproj"; fi
xcodebuild $TARGET -scheme App -configuration Release -sdk iphoneos -destination "generic/platform=iOS" -derivedDataPath build CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" build
rm -rf Payload Hive-unsigned.ipa
mkdir -p Payload
cp -R build/Build/Products/Release-iphoneos/App.app Payload/
zip -qry Hive-unsigned.ipa Payload
echo "Built Hive-unsigned.ipa"
