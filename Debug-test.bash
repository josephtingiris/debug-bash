#!/bin/bash

source Debug.bash

let Debug=0
let Debug_Level=0

while [ $Debug_Level -le 15 ]; do
    debug "debug message level $Debug_Level" $Debug_Level
    let Debug_Level=$Debug_Level+1
    let Debug=$Debug_Level
done

while [ $Debug_Level -le 101 ]; do
    debug "debug message level $Debug_Level" $Debug_Level
    let Debug_Level=$Debug_Level+1
    let Debug=$Debug_Level
done

while [ $Debug_Level -le 1050 ]; do
    debug "debug message level $Debug_Level" $Debug_Level
    let Debug_Level=$Debug_Level+100
    let Debug=$Debug_Level
done
