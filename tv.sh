#!/bin/bash
#
# Script to download .torrent files for your TV shows as they get aired.
# Requires your customized feed from myrvrss.com with your selected shows.
#
# Run as a daily cron job, downloads shows aired the previous day from now.
# Usage: tv.sh <link-to-rss-feed> <download-directory>
# Eg: tv.sh http://mytvrss.com/tvrss.xml?id=123456 ~/Downloads/torrents
#
# Transmission/uTorrent can watch for .torrent files in the download directory.
#

link="$1"
dirpath="$2"

# validate input link
match=$(echo $link | grep -o "^http://www\.mytvrss\.com/tvrss\.xml?id=[0-9]\+$")
test -z "$match" && echo "Invalid URL. Please visit mytvrss.com to generate your personalised URL" && exit 1
test -d "$dirpath" || (echo "Invalid download path: $dirpath" && exit 2)

# determine 'yesterday'
platform=`uname`
if [[ "$platform" == "Linux" ]]; then
    yest=$(date -d "`date` -1 day" +%Y-%m-%d)
elif [[ "$platform" == "Darwin" ]]; then
    yest=`date -v -1d +%Y-%m-%d`
else
    echo "Unknown platform: '$platform', exiting."
    exit 3
fi

# download .torrent for shows aired yesterday
curl -s $link | grep $yest -B5 | grep  ">.* S[0-9]\+E[0-9]\+" -o | sed 's/>//g' | while read title
do
   echo "Downloading '$title'..."
   hash=$(curl -s http://torrentz.in/feed?q=`echo $title | sed 's/ /+/g'` | grep "<link>.*$" -o | head -n2 | tail -n1 | sed 's/<link>http:\/\/torrentz\.in\///g' | sed 's/<\/link>//g' | tr '[a-z]' '[A-Z]')
   curl -s --compressed http://torcache.net/torrent/$hash.torrent > "$output_dir"/`echo $title | sed 's/ /./g'`.torrent
done
