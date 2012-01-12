if [ "$1" == "post" ]; then
    text="$(cat $2)"
    curl "http://pastebin.com/api/api_post.php" -d "api_dev_key=be4c07ee8aa9641f3b27af970a1f698f&api_option=paste&api_paste_private=1&api_paste_expire_date=10M&api_paste_code=$text"
elif [ "$1" == "get" ]; then
    curl "http://pastebin.com/raw.php?i=$2"
fi

