bin="feh"
args="--bg-scale"
interval=60

if [ -f "/tmp/wp.pid" ]; then
    pid=$(cat /tmp/wp.pid)
    kill -0 $pid
    ret=$?
    if [ $ret -eq 0 ]; then
        kill -INT $pid
        kill -0 $pid
        ret=$?
        if [ $ret -eq 0 ]; then
            kill -TERM $pid
            kill -0 $pid
            ret=$?
            if [ $ret -eq 0 ]; then
                kill -KILL $pid
                kill -0 $pid
                ret=$?
            fi
        fi
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
