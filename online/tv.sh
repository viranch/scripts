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

usage() {
    cat << EOF
Usage: $0 -l <link-to-rss-feed> -o <output-directory> [-s <search-suffix>]
EOF
}

link=""
dirpath=""
suff=""
while getopts "l:o:s:h" OPTION; do
    case $OPTION in
        l)
            link="$OPTARG"
            ;;
        o)
            dirpath="$OPTARG"
            ;;
        s)
            suff=" $OPTARG"
            ;;
        h)
            usage
            ;;
    esac
done

# validate input link
match=$(echo $link | grep -o "^http://www\.mytvrss\.com/tvrss\.xml?id=[0-9]\+$")
test -z "$match" && echo "Invalid URL. Please visit mytvrss.com to generate your personalised URL" && exit 1
test -d "$dirpath" || (echo "Invalid download path: $dirpath" && exit 2)

# determine 'yesterday'
platform=`uname`
if [[ "$platform" == "Linux" ]]; then
    yest=$(date -d "`date` -1 day" +%F)
elif [[ "$platform" == "Darwin" ]]; then
    yest=`date -v -1d +%F`
else
    echo "Unknown platform: '$platform', exiting."
    exit 3
fi

# download .torrent for shows aired yesterday
echo "Getting episode list..."
curl -s $link | grep $yest -B5 | grep  ">.* S[0-9]\+E[0-9]\+" -o | sed 's/>//g' | while read title
do
    title="$title$suff"
    query=`echo "$title" | sed 's/ /+/g'`
    echo -n "Searching '$title'... "
    hash=$(curl -s http://torrentz.in/feed?q=$query | grep "<link>.*$" -o | head -n2 | grep -v "search?q=" | sed 's/<link>http:\/\/torrentz\.in\///g' | sed 's/<\/link>//g')
    if [[ -n $hash ]]; then
        echo "found"
        fname="`echo $title | sed 's/ /./g'`.torrent"
        curl -s --compressed http://torcache.net/torrent/$hash.torrent > "$dirpath/$fname"
    else
        echo "failed"
    fi
done
