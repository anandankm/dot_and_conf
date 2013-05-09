#!/bin/bash
#
# Author: Anandan - andy.compeer@gmail.com
#                 - andy@grooveshark.com
##
# Results:
#   With 2 million rows, 8 core, 64G ram
#     Normal sort takes 100 secs, while
#     this merge sort takes 158 secs.
#     Still needs improvement.
#
##
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
num_rawin=0
rawfiles=""
tmp_dir="/tmp/merge_sort"
if [ ! -d "$tmp_dir" ]
then
    mkdir $tmp_dir
    rm -rf $tmp_dir/*
fi
rawin=$tmp_dir/rawin
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
if [ ! -z $fname ]
then
    if [ -f $fname ]
    then
        cat $fname > $rawin
    else
        echo "Given file is not a regular file"
        exit
    fi
fi
if [ -p /dev/fd/0 ]
then
    cat - > $rawin
fi
if [[ ! -z $num && $num == "yes" ]]
then
    args=$args" -n"
fi
if [[ ! -z $sep && $sep == "tab" ]]
then
    tab=1
fi

size=$(wc -l $rawin | awk '{print $1}')
qt=$[ $size / 100000 ]
rem=$[ $size % 100000 ]

function csort()
{
    if [[ ! -z $1 && -f $1 ]]
    then
        if [ $tab -eq 1 ]
        then
            sort -t'	' $args $1 > $1"_"
        else
            sort $args $1 > $1"_"
        fi
        mv $1"_" $1
        rawfiles=$rawfiles" $1"
    fi
}

if [[ $qt -eq 0  && $rem -ne 0 ]]
then
    csort $rawin
    cat $rawin
    rm -rf $rawin*
    exit
fi
if [ $rem -ne 0 ]
then
    qt=$[$qt + 1]
fi
split_dir=$rawin"_split"
mkdir -p $split_dir
rm -rf $split_dir/*
cd $split_dir
split -d -a ${#qt} -l 100000 $rawin
for i in $(ls)
do
    csort $i
done
if [ $tab -eq 1 ]
then
    sort -t'	' -m $args $rawfiles
else
    sort -m $args $rawfiles
fi
rm -rf $rawin*
