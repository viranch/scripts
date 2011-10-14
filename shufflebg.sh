bin="feh"
args="--bg-scale"
interval=60

wpdir="$1"
if [ ! -d "$wpdir" ]; then
    echo ""$wpdir:" does not exist"
    exit 1
fi
find "$wpdir" -name "*.jpg" -type f > /tmp/wplist
count=$(wc -l < /tmp/wplist)

while [ 1 ]
do
    r=$((RANDOM % $count + 1))
    wp=$(head -n$r /tmp/wplist|tail -n1)
    $bin $args "$wp"
    sleep $interval
done
