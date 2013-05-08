#!/bin/bash
#
# Author: Anandan - andy.compeer@gmail.com
#                 - andy@grooveshark.com
function usage()
{
    echo -e "
    Usage: ./merge_sort [--file=<filename>] [--sep=<separator>] [sort_options]

    Options:

    --file     - filename to be sorted
    --sep      - delimitor or field separator for sorting
    --num      - numerical-sort
    sort_options - normal options for sort [Check out 'man sort']

    "
}
function isstdin()
{
    [ -p /dev/fd/0 ] && echo 1 || echo 0
}

fname=""
sep=""
args=""
num=""
tab=0
for i in "$@"
do
    case $i in
        --file=*)
            fname=${i#--} ## Strip option prefix
            value=${fname#*=} ## value is whatever after the first =
            declare fname="$value"
            ;;
        --sep=*)
            sep=${i#--} ## Strip option prefix
            value=${sep#*=} ## value is whatever after the first =
            declare sep="$value"
            ;;
        --num)
            declare num="yes"
            ;;
        -t)
            ;;
        -n)
            ;;
        *)
            args=$args" $i"
    esac
done
if [[ ! -z $num && $num == "yes" ]]
then
    args=$args" -n"
fi
if [[ ! -z $sep && $sep == "tab" ]]
then
    tab=1
fi

num_rawin=0
rawfiles=""
tmp_dir="/tmp/merge_sort"
if [ ! -d "$tmp_dir" ]
then
    mkdir $tmp_dir
fi
rawin=$tmp_dir/rawin

function getlines()
{
    for((;;))
    do
        rf=$rawin"_$num_rawin"
        head -10000 - >$rf
        num_rawin=$[$num_rawin + 1]
        if [ $(wc -l $rf | awk '{print $1}') -eq 0 ]
        then
            rm $rf
            break
        else
            if [ $tab -eq 1 ]
            then
                sort -t'	' $args $rf > $rf"_"
            else
                sort $args $rf > $rf"_"
            fi
            mv $rf"_" $rf
            rawfiles=$rawfiles" $rf"
        fi
    done
}

if [ -p /dev/fd/0 ]
then
    getlines
fi
