#!/bin/bash
app_name="Pass For It"
app_path="/Users/maxmitch/Documents/pass for it/OSX App/"
zip_output="/Users/maxmitch/Documents/pass for it/passfor.it/passforit.zip"
project=$app_path"Pass For It.xcodeproj"
plist=$app_path"buildOptions.plist" 
output=$app_path"tmp.xcarchive" 
dev_team="3H49MXS325"

#build
xcodebuild -project "$project" -scheme "$app_name" -configuration Release clean archive -archivePath "$output" DEVELOPMENT_TEAM=$dev_team
xcodebuild -exportArchive -archivePath "$output" -exportOptionsPlist "$plist" -exportPath "$app_path"

#zip app
cd "$app_path"
zip -r -y "$zip_output" "$app_name.app"

#remove temp files
rm -rf "$app_name.app"
rm -rf "$output"

#commit
git commit "$zip_output" -m "Update OSX App - via build script"
git push origin master

#upload to website
#scp $zip_output root@185.117.22.245:/var/www/notifi.it/public_html/

#analyze results
secs=$((50))
while [ $secs -gt 0 ]; do
   echo -ne "Will close in $secs\033[0K\r"
   sleep 1
   : $((secs--))
done