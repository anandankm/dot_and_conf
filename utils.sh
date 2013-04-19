#!/bin/bash
# Author: Anandan - andy@grooveshark.com

. ~/bin/gs-specifics.sh

function home_setup()
{
    HOME=$(dirname $(readlink -f $0))
    cd $HOME
    logfile=$HOME/$(basename $0).log
    errorfile=$HOME/errorfile
    set -o pipefail
    email_to="andy@grooveshark.com"
    email_from="anandan.rangasamy@localhost"
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
    body="Mail from @script $home/$(basename $0)";
    if [ ! -z "$1" ]
    then
        subject=$1;
    fi
    if [ ! -z "$2" ]
    then
        body=$2;
    fi
    echo -e $body | /bin/mail -s "$subject" "$email_to" -- -f $email_from
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
    diff=$(($dt2-$dt1))
    echo $(($diff/86400))
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
            unwanted=$[ $(grep -n hiveconf $2 | tail -1 | awk -F":" '{print $1}') + 1 ]
            if [ ! -z "$unwanted" ]
            then
                tail -n+$unwanted $2 > $2_
                mv $2_ $2
            fi
        fi
        checkError
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
        exit 1;
    fi
}

function checkError()
{
    echo "Entering"
    if [ $(fileSize "$errorfile") -gt 0 ]
    then
        cat $errorfile | logMsg;
        err=$(cat errorfile)
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
    echo $5 | mysql -h"$1" -u"$2" -p"$3" $4 | tail -n+2
}