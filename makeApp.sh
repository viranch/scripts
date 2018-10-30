#!/bin/sh

echo "What should the Application be called (e.g. GCal)?"
#read inputline
name="$1"
echo $name

echo "What is the url (e.g. https://www.google.com/calendar/render)?"
#read inputline
url="$2"
echo $url

echo "What is the full path to the icon (e.g. /Users/username/Desktop/icon.png)?"
#read inputline
icon="$3"
echo $3




chromePath="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
appRoot="$HOME/Applications"



# various paths used when creating the app
resourcePath="$appRoot/$name.app/Contents/Resources"
execPath="$appRoot/$name.app/Contents/MacOS"
profilePath="$appRoot/$name.app/Contents/Profile"
plistPath="$appRoot/$name.app/Contents/Info.plist"

# make the directories
mkdir -p  "$resourcePath" "$execPath" "$profilePath"

# convert the icon and copy into Resources
if [ -f "$icon" ] ; then
    tiff="$resourcePath/icon.tiff"
    sips -s format tiff "$icon" --out "$tiff" --resampleWidth 128 >& /dev/null
    tiff2icns -noLarge "$tiff" >& /dev/null
    rm "$tiff"
fi

# create the executable
cat >"$execPath/$name" <<EOF
#!/bin/sh
exec "$chromePath"  --app="$url" --user-data-dir="$profilePath" "\$@"
EOF
chmod +x "$execPath/$name"

# create the Info.plist
cat > "$plistPath" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" “http://www.apple.com/DTDs/PropertyList-1.0.dtd”>
<plist version=”1.0″>
<dict>
<key>CFBundleExecutable</key>
<string>$name</string>
<key>CFBundleIconFile</key>
<string>icon</string>
</dict>
</plist>
EOF
