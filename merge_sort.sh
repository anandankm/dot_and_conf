#!/bin/bash
#
# Author: Anandan - andy.compeer@gmail.com
#                 - andy@grooveshark.com
if [[ (-z "$1" || -z "$2" || -z "$3" || -z "$4") ]]
then
    echo -e "\nUsage: merge_sort <filepath> <out-fields> <fields> <sort-options>\n\t<fields> are with respect to <out-fields>\n\t<filepath> is absolute\n\t<sort-options> without the '-'\n"
    exit 1
fi

if [ ! -f "$1" ]
then
    echo "File doesn't exist: $1"
fi

fields=$2
out_fields=$3
tmp_dir="/tmp/merge_sort"
if [ ! -d "$tmp_dir" ]
then
    mkdir $tmp_dir
fi

cd $tmp_dir
raw_in=$tmp_dir"/raw_input";

if [ "$3" == "all" ]
then
    raw_in=$1
else
    cut -f$3 $1 > $raw_in
fi
lc=$[ $(wc -l $raw_in | awk '{print $1}')/1000 ]
if [ $lc -gt 0 ]
then
    split -l 1000 -a ${#lc} $raw_in
else
    sort -$4 $raw_in
fi
