#!/bin/bash
#
# Author: Anandan - andy.compeer@gmail.com
#                 - arangasa@mathworks.com

function checkForNum()
{
    # Check for a comma separated numbers to contain 
    # the given number 
    # Example:
    #    1st argument (Number to check) : "4"
    #    2nd argument (Input numbers)   : "1,2,3,4"
    #    Checks if input numbers have 4.
    #
    local present=0
    local nums=$(addNewLine "$2" ",")
    for num in $nums
    do
        if [ $num -eq $1 ]
        then
            present=1
            break
        fi
    done
    echo $present
}
function checkForMax()
{
    # Check for a comma separated numbers to be within
    # the maximum limit
    # Example:
    #    1st argument (Maximum limit) : "4"
    #    2nd argument (Input numbers) : "1,2,3"
    #    Checks if input numbers are between 0 and 3.
    #
    local nums=$(addNewLine "$2" ",")
    local num=0
    exitOrReturn="return"
    if [ ! -z "$3" ]
    then
        exitOrReturn=$3
    fi
    for num in $nums
    do
        numregex="^[0-9]+$"
        if [[ ! ($num =~ $numregex) || $num -ge $1 || $num -lt 0 ]]
        then
            echo "Please enter numbers between 0 and "$[$1-1]
            case "$exitOrReturn" in
                return)
                    return
                    ;;
                exit)
                    exit
            esac
        fi
    done
}

function addNewLine()
{
    # Separate input by a new line using a delimiter
    # Example:
    #   1st argument (input)    : "1,2,3"
    #   2nd argument (delimiter): ","
    #   output:
    #   1
    #   2
    #   3
    #

    echo "$1" | awk -F"$2" '{for(i=1;i<=NF;i++){print $i}}'
}
