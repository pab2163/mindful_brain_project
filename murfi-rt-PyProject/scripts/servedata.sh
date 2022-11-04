#!/bin/bash



if [ "$1" == "--help" ]; then
    echo "$0 [TR(ms) [port [hostname]]]"
    exit 0
fi

tr=1200
if [ "$2" ]; then
    tr=$1
fi

port=15000
if [ "$3" ]; then
   port=$2
fi

host='127.0.0.1'
if [ "$4" ]; then
   host=$3
fi

sleep=1.2
if [ "$5" ]; then
   sleep=$4
fi

sleep $sleep
servepath=`which servenii`

if [ x"$servepath" == x ]; then
    echo "servenii not found, please add it to your path"
    exit 1
fi

if [ "$1" == "250vol" ]; then
    servenii img/img 1 250 1 68 $tr $port $host
fi

if [ "$1" == "2vol" ]; then
    servenii img/img 1 2 1 68 $tr $port $host
fi

if [ "$1" == "120vol" ]; then
    servenii img/img 1 120 1 68 $tr $port $host
fi

