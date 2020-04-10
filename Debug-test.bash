#!/bin/bash

# Copyright (C) 2013-2019 Joseph Tingiris (joseph.tingiris@gmail.com)

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

# begin Debug.bash.include

if [ ${#DEBUG} -eq 0 ] && [ ${#Debug} -eq 0 ]; then
    Debug=0
fi

if [ ${#Debug_Bash} -eq 0 ]; then
    Debug_Bashes=()
    Debug_Bashes+=(Debug.bash)

    Debug_Bash_Dirs=()
    Debug_Bash_Dirs+=(/apex)
    Debug_Bash_Dirs+=(/base)
    Debug_Bash_Dirs+=(/usr)
    Debug_Bash_Dirs+=(${BASH_SOURCE%/*})
    Debug_Bash_Dirs+=(~)

    for Debug_Bash_Dir in ${Debug_Bash_Dirs[@]}; do
        while [ ${#Debug_Bash_Dir} -gt 0 ] && [ "$Debug_Bash_Dir" != "/" ]; do # search backwards
            Debug_Bash_Source_Dirs=()
            Debug_Bash_Source_Dirs+=("${Debug_Bash_Dir}/include/debug-bash")
            Debug_Bash_Source_Dirs+=("${Debug_Bash_Dir}/include")
            Debug_Bash_Source_Dirs+=("${Debug_Bash_Dir}")
            for Debug_Bash in ${Debug_Bashes[@]}; do
                for Debug_Bash_Source_Dir in "${Debug_Bash_Source_Dirs[@]}"; do
                    Debug_Bash_Source=${Debug_Bash_Source_Dir}/${Debug_Bash}

                    if [ -r "${Debug_Bash_Source}" ]; then
                        source "${Debug_Bash_Source}"
                        break
                    else
                        unset -v Debug_Bash_Source
                    fi
                done
                [ ${Debug_Bash_Source} ] && break
            done
            [ ${Debug_Bash_Source} ] && break

            Debug_Bash_Dir=${Debug_Bash_Dir%/*} # search backwards
        done
        [ ${Debug_Bash_Source} ] && break
    done
fi

if [ ${#Debug_Bash_Source} -eq 0 ] || [ ! -r "${Debug_Bash_Source}" ]; then
    echo "${Debug_Bash} file not readable"
    exit 1
fi

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
