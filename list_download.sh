path="$1"; shift
curl -L "$path" $@ | grep -o 'href="[^"]*\.mkv"' |sed 's/href=//g;s/"//g' | sort -u | while read p; do
    echo "$path/$p"
done
