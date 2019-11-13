#!/bin/bash

# This is a bash include file that contains useful debug related functions.

# Copyright (C) 2013 Joseph Tingiris (joseph.tingiris@gmail.com)

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

#
# 20191113, joseph.tingiris@gmail.com, maintenance review (still using daily); moved primary repo from local svn to github
# 20130228, joseph.tingiris@gmail.com

export PATH="/usr/local/bin:/usr/local/sbin:/bin:/usr/bin:/sbin:/usr/sbin:${PATH}"

#
# Global_Variables (that do not require dependencies)
#

if [ "${Debug}" == "" ]; then
    if [ "${DEBUG}" == "" ]; then
        let Debug=0
    else
        let Debug=${DEBUG}
    fi
else
    let Debug=${Debug}
fi

# bash environment (overrides)

if [ "$TERM" == "" ]; then export TERM="ansi"; fi

#
# Functions
#

# an example, prototype using debugFunction
function _prototypeFunction() {
    debugFunction $@ # call debugFunction when the function finished

    # begin function logic

    printf "Hello World!\n"

    # end function logic

    debugFunction $@ # call debugFunction again to know when the function finished
}

# output a message & 'abort' (exit) with a return code
function aborting() {
    debugFunction $@

    # begin function logic

    if [ "$2" == "" ]; then
        local -i return_code="$2"
    else
        local -i return_code=9
    fi
    local aborting_message="aborting, $1 ($return_code) ..."

    (>&2 printf "\n$aborting_message\n\n")

    exit $return_code

    # end function logic

    debugFunction $@
}

# output consistently formatted debug messages (in color if TERM supports it)
function debug() {

    # begin function logic

    local debug_identifier_minimum_width=11
    local debug_function_name_minimum_width=16

    local -i debug_color=1
    local debug_message="$1"
    local -i debug_level="$2"
    local debug_function_name="$3"
    local -i debug_output=0

    if [ "$debug_function_name" == "" ] && [ "$debugFunction_Name" != "" ]; then
        debug_function_name=$debugFunction_Name
    else
        # automatically determine the caller
        local debug_caller_name=""
        local -i caller_frame=0
        while [ $caller_frame -lt 10 ]; do
            local debug_caller=$(caller $caller_frame)
            ((caller_frame++))

            if [ "$debug_caller" == "" ]; then break; fi

            # do not output anything for these callers
            if [[ $debug_caller == *List* ]]; then continue; fi

            # omit these callers; function names that have these strings in them will *not* be debugged
            if [[ $debug_caller == *debug* ]]; then continue; fi
            if [[ $debug_caller == *question* ]]; then continue; fi
            if [[ $debug_caller == *step* ]]; then continue; fi

            local debug_caller_name=${debug_caller% *}
            local debug_caller_name=${debug_caller_name#* }
            if [ "$debug_caller_name" != "" ]; then break; fi
        done
        local debug_function_name=$debug_caller_name
    fi

    if [ $Debug -ge $debug_level ]; then
        local -i debug_output=1
    fi

    if [ $debug_level -eq 0 ]; then
        # any debug with a level of zero; message will be displayed
        local -i debug_output=1
    fi

    if [ $debug_output -eq 1 ]; then

        # set the color, if applicable
        if [ "$TERM" == "ansi" ] || [ "$TERM" == "tmux" ] || [[ "$TERM" == *"color"* ]] || [[ "$TERM" == *"xterm"* ]]; then
            if [ $debug_level -ge 256 ]; then
                let debug_color=$debug_level/256
            else
                let debug_color=$debug_level
            fi
            if [ $debug_level -lt 15 ]; then
                (>&2 printf "%s" ${Tput_Bold})
                (>&2 printf "%s" "$(tput setaf $debug_color 2> /dev/null)")
            else
                if [ $debug_level -le 101 ]; then
                    local bg_color fg_color
                    let local color_select=16
                    let local bg_select=0
                    let local fg_select=0
                    for fg_color in {0..15}; do
                        let fg_select=$fg_select+1
                        color_select=$fg_select
                        for bg_color in {1..11}; do
                            if [ $bg_color -eq $fg_color ]; then continue; fi
                            let bg_select=$bg_select+1
                            color_select=$bg_select
                            if [ $color_select -ne $debug_level ]; then continue; fi
                            local tput_setaf=$(tput setaf $fg_color 2> /dev/null)
                            local tput_setab=$(tput setab $bg_color 2> /dev/null)
                        done
                    done
                    #(>&2 printf "%s" ${Tput_Bold})
                    (>&2 printf "%s" ${tput_setab})
                    (>&2 printf "%s" ${tput_setaf})
                    let debug_color=$debug_color*5
                else
                    (>&2 printf "%s" $tput_smso)
                    let debug_color=$debug_color+12
                    (>&2 printf "%s" "$(tput setab $debug_color 2> /dev/null)")
                fi
            fi

        fi

        # display the appropriate message
        local debug_identifier="debug [$debug_level]"
        let local debug_identifier_pad=${debug_identifier_minimum_width}-${#debug_identifier}
        if [ ${debug_identifier_pad} -lt 0 ]; then debug_identifier_pad=0; fi
        if [ "$debug_function_name" != "" ] && [ $Debug -ge 15 ]; then
            let local debug_function_name_pad=${debug_function_name_minimum_width}-${#debug_function_name}
            if [ ${debug_function_name_pad} -lt 0 ]; then debug_function_name_pad=0; fi
            (>&2 printf "%s%${debug_identifier_pad}s : %s : %s()%${debug_function_name_pad}s : %s\n" "$debug_identifier" " " "${Hostname}" "${debug_function_name}" " " "${debug_message}${Tput_Sgr0}")
        else
            (>&2 printf "%s%${debug_identifier_pad}s : %s : %s\n" "$debug_identifier" " " "${Hostname}" "${debug_message}${Tput_Sgr0}")
        fi

        # reset the color, if applicable
        if [ "$TERM" == "ansi" ] || [ "$TERM" == "tmux" ] || [[ "$TERM" == *"color"* ]] || [[ "$TERM" == *"xterm"* ]]; then
            (>&2 printf "%s" ${Tput_Sgr0})
        fi
    fi

    unset debugFunction_Name

    # end function logic

}

# output a tput color chart
function debugColors() {

    # begin function logic

    if [ $Debug -lt 1000 ]; then return; fi # this function provides little value to an end user

    if [ "$TERM" == "ansi" ] || [ "$TERM" == "tmux" ] || [[ "$TERM" == *"color"* ]] || [[ "$TERM" == *"xterm"* ]]; then
        local color column line

        printf "Standard 16 colors\n"
        for ((color = 0; color < 17; color++)); do
            printf "|%s%3d%s" "$(tput setaf "${color}" 2> /dev/null)" "${color}" "${Tput_Sgr0}"
        done
        printf "|\n\n"

        printf "Colors 16 to 231 for 256 colors\n"
        for ((color = 16, column = line = 0; color < 232; color++, column++)); do
            printf "|"
            ((column > 5 && (column = 0, ++line))) && printf " |"
            ((line > 5 && (line = 0, 1)))   && printf "\b \n|"
            printf "%s%3d%s" "$(tput setaf "${color}" 2> /dev/null)" "${color}" "${Tput_Sgr0}"
        done
        printf "|\n\n"

        printf "Greyscale 232 to 255 for 256 colors\n"
        for ((; color < 256; color++)); do
            printf "|%s%3d%s" "$(tput setaf "${color}" 2> /dev/null)" "${color}" "${Tput_Sgr0}"
        done
        printf "|\n"
    else
        printf "debug colors not supported\n"
    fi

    # end function logic

}

# outputs calling function @ debug_level > 100
function debugFunction() {

    # begin function logic

    local debug_caller=$(caller 0)
    local debug_caller_name=${debug_caller% *}
    local debug_caller_name=${debug_caller_name#* }

    if [ "$debug_caller_name" != "" ]; then
        local debug_function_name=$debug_caller_name
    else
        local debug_function_name="UNKNOWN"
    fi

    local debug_function_switch=debugFunction_Name_$debug_function_name

    if [ "$debugFunction_Name" == "" ]; then
        debugFunction_Name="main"
    fi

    if [ "${!debug_function_switch}" == "on" ]; then
        local debug_function_status="finished"
        unset ${debug_function_switch}
    else
        local debug_function_status="started"
        export ${debug_function_switch}="on"
    fi

    local debug_function_message="$debug_function_status function $debug_function_name() $@"
    #local debug_function_message="${debug_function_message%"${debug_function_message##*[![:space:]]}"}" # trim trailing spaces

    if [[ "$debug_function_name" == debug* ]]; then
        local debug_function_level=1000 # only debugFunction debug functions at an extremely high level
    else
        local debug_function_level=100
    fi

    debug "$debug_function_message" $debug_function_level $debug_function_name

    # end function logic

}

# outputs a separator line
function debugSeparator() {

    # begin function logic

    local separator_character="$1"
    local -i debug_level="$2"
    local -i separator_length="$3"

    if [ "$separator_character" == "" ]; then separator_character="="; fi
    if [ $separator_length -eq 0 ]; then separator_length=80; fi

    local separator=""
    while [ $separator_length -gt 0 ]; do
        local separator+=$separator_character
        local -i separator_length=$((separator_length-1))
    done

    debug $separator $debug_level

    # end function logic

}

# outputs a padded name=value variable pair
function debugValue() {

    # begin function logic

    local variable_name=$1
    local -i debug_level="$2"
    local variable_comment="$3"

    local variable_value=${!variable_name}
    if [ "$variable_value" == "" ]; then variable_value="Null"; fi

    # manual padding; call debug() to display it
    local -i variable_pad=25 # the character position to pad to
    local -i variable_padded=0
    local -i variable_length=${#variable_name}
    local -i variable_position=$variable_pad-$variable_length

    while [ $variable_padded -le $variable_position ]; do
        local variable_name+=" "
        local -i variable_padded=$((variable_padded+1))
    done

    if [ "$variable_comment" != "" ]; then variable_value+=" ($variable_comment)"; fi

    debug "$variable_name = $variable_value" $debug_level

    # end function logic

}

# checks to make sure a dependent executable exists in the PATH and aborts if it doesn't
function dependency() {

    # begin function logic

    local dependency dependencies=($@)

    for dependency in ${dependencies[@]}; do
        if [ "${dependency}" == "" ]; then
            continue
        fi

        if ! type -t ${dependency} &> /dev/null; then
            aborting "dependency '${dependency}' alias, file, and/or function not found" 2
        fi
    done
    unset dependency dependencies


    # end function logic

}

#
# Functions (deprecated)
#

function Debug_Variable() {
    debugValue $@
}

#
# Main
#

Debug_Dependencies=()

# validate these dependencies exist
Debug_Dependencies+=(awk)
Debug_Dependencies+=(hostname)
Debug_Dependencies+=(printf)
Debug_Dependencies+=(readlink)
Debug_Dependencies+=(sed)
Debug_Dependencies+=(tput)
Debug_Dependencies+=(logname)
Debug_Dependencies+=(who)

dependency ${Debug_Dependencies[@]}

# Global_Variables (that do require dependencies)

if [ "$Hostname" == "" ]; then Hostname=$(hostname -s 2> /dev/null); fi

if [ "$TERM" == "ansi" ] || [ "$TERM" == "tmux" ] || [[ "$TERM" == *"color"* ]] || [[ "$TERM" == *"xterm"* ]]; then
    if [ "$Tput_Bold" == "" ]; then Tput_Bold="$(tput bold 2> /dev/null)"; fi
    if [ "$Tput_Setab" == "" ]; then Tput_Setab="$(tput setab 2> /dev/null)"; fi
    if [ "$Tput_Setaf" == "" ]; then Tput_Setaf="$(tput setaf 2> /dev/null)"; fi
    if [ "$Tput_Smso" == "" ]; then Tput_Smso="$(tput smso 2> /dev/null)"; fi
    if [ "$Tput_Sgr0" == "" ]; then Tput_Sgr0="$(tput sgr0 2> /dev/null)"; fi
fi

if [ "$Whom" == "" ]; then Whom=$(who -m 2> /dev/null); fi

if [ "$Who" == "" ]; then Whom=$(logname 2> /dev/null); fi
if [ "$Who" == "" ]; then Who="${Whom%% *}"; fi
if [ "$Who" == "" ]; then Who=anoymous; fi

if [ "$Who_Ip" == "" ]; then Who_Ip="${Whom#*(}"; Who_Ip="${Who_Ip%)*}"; fi
if [ "$Who_Ip" == "" ] && [ "$SSH_CLIENT" != "" ]; then Who_Ip=${SSH_CLIENT%% *}; fi
if [ "$Who_Ip" == "" ]; then Who_Ip="127.0.0.1"; fi
