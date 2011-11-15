bin="feh"
args="--bg-scale"
interval=60

if [ -f "/tmp/wp.pid" ]; then
    kill -0 `cat /tmp/wp.pid`
    ret=$?
    if [ $ret -eq 0 ]; then
        echo "Another instance of the shuffler is already running. Exiting..."
        exit 2
    fi
fi

wpdir="$1"
if [ ! -d "$wpdir" ]; then
    echo ""$wpdir:" does not exist"
    exit 1
fi

echo $$ > /tmp/wp.pid
find "$wpdir" -name "*.jpg" -type f > /tmp/wplist
count=$(wc -l < /tmp/wplist)

while [ 1 ]
do
    r=$((RANDOM % $count + 1))
    wp=$(head -n$r /tmp/wplist|tail -n1)
    $bin $args "$wp"
    echo "$wp" > /tmp/wp
    sleep $interval
done
