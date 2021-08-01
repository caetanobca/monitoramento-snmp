#!/bin/bash


n=$(($RANDOM%20))
pids=()

for i in $(seq 0 $n); do 
    ./processoTeste.sh  &
    pids+=$!
    sleep 10
done

sleep 60

for ((j=$n; j>=0; j--)); do 
    kill -KILL $j
    sleep 13
done
