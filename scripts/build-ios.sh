#!/bin/bash
# Builds an unsigned Hive.ipa on a Mac (used by the GitHub workflow, or run it yourself on a Mac).
set -eo pipefail
echo "== Node $(node -v), npm $(npm -v)"; xcodebuild -version
echo "== Installing"
npm install --no-audit --no-fund
echo "== Creating the iOS project"
rm -rf ios
npx cap add ios
echo "== App icon and splash screen"
npx @capacitor/assets generate --ios || echo "Icon generation failed; building with the default icon."
npx cap sync ios
echo "== Photo picker permissions"
P=ios/App/App/Info.plist
/usr/libexec/PlistBuddy -c "Add :NSPhotoLibraryUsageDescription string Choose a photo for your profile." "$P" || true
/usr/libexec/PlistBuddy -c "Add :NSCameraUsageDescription string Take a photo for your profile." "$P" || true
echo "== Building with Xcode"
if [ -d ios/App/App.xcworkspace ]; then TARGET="-workspace ios/App/App.xcworkspace"; else TARGET="-project ios/App/App.xcodeproj"; fi
set +e
xcodebuild $TARGET -scheme App -configuration Release -sdk iphoneos -destination "generic/platform=iOS" -derivedDataPath build \
  -skipPackagePluginValidation -skipMacroValidation \
  CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" build > xcodebuild.log 2>&1
code=$?
set -e
if [ $code -ne 0 ]; then
  echo "== Xcode failed. The errors:"
  grep -E "error:|fatal error|BUILD FAILED" xcodebuild.log | head -40 || true
  echo "== Last lines of the build log:"
  tail -40 xcodebuild.log
  exit $code
fi
echo "== Packaging the .ipa"
APP=$(find build/Build/Products -maxdepth 2 -name "*.app" -path "*iphoneos*" | head -1)
rm -rf Payload Hive-unsigned.ipa
mkdir -p Payload
cp -R "$APP" Payload/
zip -qry Hive-unsigned.ipa Payload
echo "Built Hive-unsigned.ipa"
