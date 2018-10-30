output=`curl -s "$2" -H 'Accept-Encoding: gzip, deflate, br' -H 'Accept-Language: en-US,en;q=0.8' -H 'Upgrade-Insecure-Requests: 1' -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/61.0.3163.100 Safari/537.36' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8' -H 'Cache-Control: max-age=0' -H 'Cookie: mumbo jumbo here' -H 'Connection: keep-alive' --compressed`
seller=`echo $output| html2text -nobs | grep '\*\*\*\*\*\*' | gsed 's/\**//g;s/,/ /g'`
echo $output | html2text -nobs | grep qty | while read line; do
    currency=`echo $line| awk '{print $1}'`
    denomination=`echo $line| awk '{print $2}'`
    points=`echo $line| awk '{print $3}'`
    echo $2, $seller, $1, $currency, $denomination, $points
done
