#!/bin/bash
# Author: Anandan - andy@grooveshark.com
#                 - andy.compeer@gmail.com

. /home/data/bin/gs-specifics.sh

function home_setup()
{
    HOME=$(dirname $(readlink -f $0))
    cd $HOME
    ## appendix for log and error files
    appendix=""
    ## Initialize background process ids #bgpids
    ## Append bgpids with pids, and other relevant info
    ## separated by colon [:]
    bgpids=""
    logdir=$HOME
    logfile=$logdir/$(basename $0).log
    errorfile=$logdir/$(basename $0).errorfile
    set -o pipefail
    email_to="andy@grooveshark.com"
    email_from="anandan.rangasamy@localhost"
}

function append_pid()
{
    if [ -z "$1" ]
    then
        appendix=$$
    else
        appendix=$1
    fi
    append_logfile $appendix
    append_errfile $appendix
}

function append_logfile()
{
    if [ ! -z "$1" ]
    then
        logfile=$logdir/$(basename $0).log"_$1"
    fi
}

function append_errfile()
{
    if [ ! -z "$1" ]
    then
        errorfile=$logdir/$(basename $0).errorfile"_$1"
    fi
}

function set_logdir()
{
    if [[ (! -z "$1") && (-d "$1") ]]
    then
        logdir=$1
        if [ -z "$appendix" ]
        then
            logfile=$logdir/$(basename $0).log
            errorfile=$logdir/$(basename $0).errorfile
        else
            logfile=$logdir/$(basename $0).log"_$appendix"
            errorfile=$logdir/$(basename $0).errorfile"_$appendix"
        fi
    fi
}

function logMsg()
{
   tme=$(date +"%Y-%m-%d %T");
   if [ -z "$1" ]
   then
       echo "[$tme]" $(cat -) >> $logfile;
   else
       echo "[$tme] $1" >> $logfile;
   fi
}

function mail()
{
    subject="Mail from @script $HOME/$(basename $0)";
    body="Mail from @script $HOME/$(basename $0)";
    attachment=""
    if [ ! -z "$1" ]
    then
        subject=$1;
    fi
    if [ ! -z "$2" ]
    then
        body=$2;
    fi
    if [ ! -z "$3" ]
    then
        attachment=$3;
    fi
    if [[ (! -z "$attachment") && (-f $attachment) ]]
    then
        export EMAIL=$email_from && echo -e $body | mutt -a "$attachment" -s "$subject" -- $email_to
    else
        echo -e $body | /bin/mail -s "$subject" "$email_to" -- -f $email_from
    fi
}

## Look for a given stop file for a graceful kill

function is_SIGEXIT()
{
    stop_file=$@
    if [[ (! -z "$stop_file") && (-f "$stop_file") ]]
    then
        if [ $(cat $stop_file) == "stop $$" ]
        then
            exit
        fi
    fi
}

## Find the number of hours since the process id <proc_id>
## was started

function hrs_since()
{
    proc_id=$$
    if [ ! -z $1 ]
    then
        proc_id=$1
    fi
    etime=$(ps -p $proc_id -o etime | tail -1 | sed -e 's/^ *//g' -e 's/ *$//g' | awk -F":" '{if(NF>2){print $1}}')
    if [ ! -z $etime ]
    then
        echo $etime | awk -F"-" '{if(NF==2){print $1*24 + $2}else{print $1+0}}'
    else
        echo 0
    fi
}

## Check for a file 'stop_file', for graceful kill
## Execute the given command, and if it returns more than 0,
## then return or wait for 1 more hour and check the result of the
## command. This is recursive for only 10 hrs. Useful when used as a cron job
## and needs to check for a precursor job completion.
function check_sleep()
{
    is_SIGEXIT stop_file
    cmd=$@
    cnt=$($cmd)
    success=$?
    is_int=$(isInteger $cnt)
    if [[ ($is_int -eq 1 && $cnt -gt 0) || ($is_int -eq 0 && $success -eq 0) ]]
    then
        return
    else
        if [ $(hrs_since) -gt 10 ]
        then
            logMsg "More than 10 hrs since starting this script. Quitting."
            exit
        else
            logMsg "Sleeping for an hour"
            sleep 1h
            check_streams $cmd
        fi
    fi
}

## Check if the script is provided with stdin

function isstdin()
{
    [ -p /dev/fd/0 ] && echo 1 || echo 0
}

function today()
{
    date +"%Y-%m-%d"
}

function yesterday()
{
    date +"%Y-%m-%d" --date="yesterday"
}

function date2ts()
{
    date +"%s" --date="$1"
}

function ts2date()
{
    date --utc +"%Y-%m-%d" --date="1970-01-01 $1 sec"
}

# plus or minus a given date
# dateNDays "2012-07-07" "-2"
function dateNDays()
{
    date +"%Y-%m-%d" --date="$1 $2 days"
}
# date given a bash date command readable string
# dateReadable "3 weeks ago"
function dateReadable()
{
    date +"%Y-%m-%d" --date="$1"
}

# positive if the second date is more than the first
# negative otherwise
function daydiff()
{
    dt1=$(date2ts $1)
    dt2=$(date2ts $2)
    rem=$[($dt2 - $dt1) % 86400]
    diff=$[($dt2 - $dt1) / 86400]
    if [ $rem -ne 0 ]
    then
        if [ $diff -le 0 ]
        then
            echo $[$diff - 1]
        else
            echo $[$diff + 1]
        fi
    else
        echo $diff
    fi
}

# distance between dates
function daydiffmod()
{
    diff=$(daydiff $1 $2)
    if (($diff<0))
    then
        echo $((-1*$diff))
    else
        echo $diff
    fi
}

# Return all the dates space separated
# between the daterange <start-date> <end-date>
# useful in a for loop
# example: for i in daterange 2012-01-31 2012-01-04
#          do
#              echo $i
#          done
function daterange()
{
    if [[ -z $1 || -z $2 ]]
    then
        echo "daterange: please provide 2 date values"
        echo "usage: daterange <start-date> <end-date> [<interval>]"
        exit 1
    fi
    interval=1
    if [ ! -z $3 ]
    then
        if [ $3 -lt 0 ]
        then
            echo "Interval cannot be negative"
            exit 1
        fi
        interval=$3
    fi
    sdate=$1
    edate=$2
    diff=$[$(daydiff $1 $2)/$interval]
    if [ $diff -lt 0 ]
    then
        interval=$[-1*$interval]
        diff=$[-1*$diff]
    fi
    result=$sdate
    for ((i=0;i<$diff;i++))
    do
        sdate=$(dateNDays $sdate $interval)
        result=$result" "$sdate
    done
    echo "$result"
}

# Run a hive query given a query string
runHive()
{
   if [ ! -z "$1" ]
   then
       if [ -z "$2" ]
       then
           logMsg "Running sudo -u hdfs hive query.."
           sudo -u hdfs hive -S -e "$1" >> $logfile 2>$errorfile
       else
           logMsg "Running hive query into $2"
           hive -S -e "$1" > $2 2>$errorfile
       fi
       checkError
   fi
}

# Run a hive query given a sql file
runHiveSqlFile()
{
    if [ ! -z "$1" ]
    then
        if [ -z "$HIVE_CONF_STRING" ]
        then
            # set HIVE_CONF_STRING variable
            # e.g. HIVE_CONF_STRING="-hiveconf a=b -hiveconf c=d"
            HIVE_CONF_STRING=""
        fi
        export HIVE_OPTS="$HIVE_CONF_STRING $HIVE_CONF_DEF_STRING"
        if [ -z "$2" ]
        then
           logMsg "Running sudo -u hdfs hive query.."
           sudo -u hdfs sh -c "
           export HIVE_OPTS=\"$HIVE_OPTS $HIVE_CONF_STRING\";
           hive -S -f "$1"
           " >> $logfile 2>$errorfile
        else
            logMsg "Running hive query into $2.."
            hive -S -f "$1" > $2 2>$errorfile
            rm_hive_conf $2
        fi
        checkError
    fi
}

function rm_hive_conf()
{
    if [ -f $1 ]
    then
        unwanted=$[ $(grep -n hiveconf $1 | tail -1 | awk -F":" '{print $1}') + 1 ]
        if [ ! -z "$unwanted" ]
        then
            tail -n+$unwanted $1 > $1_
            mv $1_ $1
        fi
    fi
}

function bg_hive()
{
    us_str="
        Usage:
        bg_hive -i [Optional args]

        Required Arguments:
        -i  - Input file to be executed by hive

        Optional Arguments:
        -o       - Output file for hive to write
        -b       - If the hive job needs to be a background job
                   provide suffix for the errorfile with this option
        --bgopts - Provide background options to be appended to
                   background job pid [@bgpid] variable colon [:]
                   separated. The first value will be appended to
                   the error file specific to the background job.

                   ";

    ARGS=$(getopt -o i:o::b:: -l bgopts:: -n "bg_hive" -- "$@")
    if [ $? -ne 0 ]
    then
        echo $us_str
        unset ARGS
        exit 1
    fi
    eval set -- "$ARGS"
    unset ARGS
    in_file=
    out_file=
    run_bg=""
    bg_ef_suffix=
    bg_options=
    while true
    do
        case "$1" in
            -i)
                case "$2" in
                    "") echo "$us_str";unset us_str;exit 2;shift 2;;
                    *) in_file=$2 >&2;shift 2;;
                esac;;
            -o)
                case "$2" in
                    "") shift 2;;
                    *) out_file=$2 >&2;shift 2;;
                esac;;
            -b)
                run_bg="&";
                case "$2" in
                    "") shift 2;;
                    *) bg_ef_suffix=$2 >&2;shift 2;;
                esac;;
            --bgopts)
                run_bg="&";
                case "$2" in
                    "") shift 2;;
                    *) bg_options=$2 >&2;shift 2;;
                esac;;
            --)
                shift; break;;
            *)
                echo "$us_str"; unset us_str;
                exit 1;;
        esac
    done
    if [ ! -z $in_file ]
    then
        if [[ (-z "$bg_ef_suffix") && (! -z $bg_options) ]]
        then
            bg_ef_suffix=$(echo $bg_options | awk -F":" '{print $1}')
        fi
        if [ ! -z "$run_bg" ]
        then
            bg_ef_suffix="_$bg_ef_suffix"
            if [ -z "$bg_options" ]
            then
                bg_options="$bg_ef_suffix"
            fi
        fi
        if [ -z "$HIVE_CONF_STRING" ]
        then
            # set HIVE_CONF_STRING variable
            # e.g. HIVE_CONF_STRING="-hiveconf a=b -hiveconf c=d"
            HIVE_CONF_STRING=""
        fi
        export HIVE_OPTS="$HIVE_CONF_STRING $HIVE_CONF_DEF_STRING"
        if [ -z "$out_file" ]
        then
            logMsg "Running sudo -u hdfs hive query.."
            if [ ! -z "$run_bg" ]
            then
                sudo -u hdfs sh -c "
                export HIVE_OPTS=\"$HIVE_OPTS $HIVE_CONF_STRING\";
                hive -S -f "$in_file"
                " >> $logfile 2>$errorfile"$bg_ef_suffix" &
                bgpids=$bgpids" $!:$bg_options"
            else
                sudo -u hdfs sh -c "
                export HIVE_OPTS=\"$HIVE_OPTS $HIVE_CONF_STRING\";
                hive -S -f "$in_file"
                " >> $logfile 2>$errorfile"$bg_ef_suffix"
                checkError
            fi
        else
            logMsg "Running hive query into $out_file.."
            if [ ! -z "$run_bg" ]
            then
                hive -S -f "$in_file" > $out_file 2>$errorfile"$bg_ef_suffix" &
                bgpids=$bgpids" $!:$bg_options"
            else
                hive -S -f "$in_file" > $out_file 2>$errorfile"$bg_ef_suffix"
                rm_hive_conf $out_file
                checkError
            fi
        fi
    fi
}

### Check for bgpids set and wait for those
### background jobs to complete
###
###  - Assumes bgpids the first value in colon [:]
###    separated $bgpids
###  - Assumes errorfiles are suffixed by the second
###    value in colon [:] separated $bgpids

function chk_bgjobs()
{
    error_occ=0
    for bgpid_v in $bgpids
    do
        bgpid=$(echo $bgpid_v | awk -F":" '{print $1}')
        wait $bgpid
        exitcd=$?
        v=$(echo $bgpid_v | awk -F":" '{print $2}')
        if [ $exitcd -ne 0 ]
        then
            errf=$errorfile"_"$v
            if [[ (-f $errf) && ($(fileSize $errf) -gt 0) ]]
            then
                if [[ ! "$(cat $errf)" =~ "rmr: DEPRECATED: Please use 'rm -r' instead." ]]
                then
                    logMsg "Error @$errf"
                    cat $errf | logMsg
                    subject="Error occurred @script $HOME/$(basename $0)";
                    mail "$subject" "$(cat $errf)"
                    > $errf
                    error_occ=1
                fi
            fi
        fi
        logMsg "Job done for pid $bgpid with info: [$bgpid_v]."
    done
    if [ $error_occ -eq 1 ]
    then
        logMsg "Error occurred while checking bg jobs. Exitting script."
        exit
    fi
}

# Get owner name for a file/directory
function getUser()
{
    ll $1 | awk '{print $4}'
}

# Get group name for a file/directory
function getGroup()
{
    ll $1 | awk '{print $5}'
}

function isInteger()
{
    if [[ !($1 =~ ^[0-9]+$) ]]
    then
        echo 0
    else
        echo 1
    fi
}

function errorlogMail()
{
    if [ $(fileSize "$errorfile") -gt 0 ]
    then
        logMsg "Error occurred";
        cat $errorfile | logMsg;
        subject="Error occurred @script $HOME/$(basename $0)";
        mail "$subject" "$(cat $errorfile)"
        > $errorfile
    fi
}

function checkError()
{
    if [ $(fileSize "$errorfile") -gt 0 ]
    then
        cat $errorfile | logMsg;
        err=$(cat $errorfile)
        > $errorfile
        # Check for stupid updated hive not using the latest hadoop rm -r
        if [[ ! "$err" =~ "rmr: DEPRECATED: Please use 'rm -r' instead." ]]
        then
            logMsg "Error occurred";
            logMsg "Exitting";
            if [[ (! -z "$1") && ("$1" == "and_mail") ]]
            then
                subject="Error occurred @script $HOME/$(basename $0)";
                echo "sending error email"
                mail "$subject" "$err"
            fi
            exit 1;
        fi
    fi
}

# Find the number of unique words in a file
function uniq_words()
{
    if [[ (-z "$1") || (! -f $1) ]]
    then
        echo 0
    else
        echo $(awk '{for(i=1;i<=NF;i++){s[$i]=0;}}END{print length(s)}' $1)
    fi
}

# Find the number of lines in a file
function fileSize()
{
    if [ -z "$1" ]
    then
        echo 0
    else
        echo $(wc -l $1 | awk '{print $1}')
    fi
}

# MySQL command over the network
# Do not pass "SELECT * FROM <tablename>"
# "*" would be expanded to all files in your current working directory.
function mysql_cmd()
{
    if [[ (-z "$1") || (-z "$2") || (-z "$3") || (-z "$4") || (-z "$5") ]]
    then
        logMsg "Please provide mysql credentials: <host> <user> <pass> <db> <query>."
        exit 1
    fi
    echo $5 | mysql -h"$1" -u"$2" -p"$3" $4 | tail -n+2 2>$errorfile
    checkError
}
