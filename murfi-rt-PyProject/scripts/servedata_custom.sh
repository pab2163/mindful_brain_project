#!/bin/bash



if [ "$1" == "--help" ]; then
    echo "$0 [TR(ms)] [volumes] [path_spec]"
    exit 0
fi

tr=$1
volumes=$2
path=$3
port=15000
host='127.0.0.1'
sleep=1.2

echo $path

sleep $sleep
servepath=`which servenii`

if [ x"$servepath" == x ]; then
    echo "servenii not found, please add it to your path"
    exit 1
fi


servenii ../subjects/sub-R61MBNFD999/img/img 4 ${volumes} 1 68 $tr $port $host


# if [ "$1" == "250vol" ]; then
#     servenii img/img 1 250 1 68 $tr $port $host
# fi

# if [ "$1" == "2vol" ]; then
#     servenii img/img 1 2 1 68 $tr $port $host
# fi

# if [ "$1" == "120vol" ]; then
#     servenii img/img 1 120 1 68 $tr $port $host
# fi

