#!/bin/bash

# Copyright (C) 2018 Joseph Tingiris (joseph.tingiris@gmail.com)

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.


if [ "$DEBUG" == "" ] && [ "$Debug" == "" ]; then
    Debug=0
fi

# begin Debug.bash.include

Debug_Bash="Debug.bash"
Debug_Bash_Dirs=()
Debug_Bash_Dirs+=($(dirname $(readlink -e $BASH_SOURCE)))
for Debug_Bash_Dir in ${Debug_Bash_Dirs[@]}; do
    while [ "$Debug_Bash_Dir" != "" ] && [ "$Debug_Bash_Dir" != "/" ]; do # search backwards
        Debug_Bash_Source_Dirs=()
        Debug_Bash_Source_Dirs+=("${Debug_Bash_Dir}")
        Debug_Bash_Source_Dirs+=("${Debug_Bash_Dir}/include")
        Debug_Bash_Source_Dirs+=("${Debug_Bash_Dir}/include/debug-bash")
        for Debug_Bash_Source_Dir in ${Debug_Bash_Source_Dirs[@]}; do
            Debug_Bash_Source=${Debug_Bash_Source_Dir}/${Debug_Bash}
            if [ -r "${Debug_Bash_Source}" ]; then
                source "${Debug_Bash_Source}"
                break
            else
                unset Debug_Bash_Source
            fi
        done
        if [ "$Debug_Bash_Source" != "" ]; then break; fi
        Debug_Bash_Dir=$(dirname "$Debug_Bash_Dir") # search backwards
    done
done
if [ "$Debug_Bash_Source" == "" ]; then echo "$Debug_Bash file not found"; exit 1; fi
unset Debug_Bash_Dir Debug_Bash

# end Debug.bash.include

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
