#!/bin/bash
# Copyright (c) 2018, Andrew Turpin
# License MIT: https://opensource.org/licenses/MIT

_version="0.1"

function displayHelp(){
 echo "Usage pingtest [OPTION]... [FILE]";
 echo "   Tries to ping a list of ip's or url's provided in a file or at command line";
 echo "   and if ICMP packets are blocked (ping fails) the program will attempt";
 echo "   to connect via http/s at the port specified";
 echo " ";
 echo "  OPTIONS:";
 echo "    -f, --file      supply file name with ip's or urls to test";
 echo "                    the file format is [server-display-name] | ip/url:port and";
 echo "                    if ping is blocked (e.g. AWS) then the test will try curl. ";
 echo "    -v, --verbose   display vebose details and progress bar.  Works with -f option only.";
 echo "    -m, --markdown  formats the output in markdown.  Works with -v option only.";
 echo "    -s, --server    pings a single server given in form [server-ip/url:port]";
 echo "        --help      display this help and exit";
 echo "        --version   display version and exit";
 echo "";
 echo "  EXAMPLE(s):";
 echo "      pingtest -f [ipfile]";
 echo "      pingtest --server [server-ip/url:port]";
 echo "";
}

function displayVersion(){
 echo "pingtest (bank-builder utils) version $_version";
 echo "Copyright (C) 2018, Andrew Turpin";
 echo "License MIT: https://opensource.org/licenses/MIT";
 echo "";
}

function ProgressBar {
# $1 = progress_number, $2 = total
# Author: Teddy Skarin, licensed under The Unlicense, https://github.com/fearside/ProgressBar/

    let _progress=(${1}*100/${2}*100)/100
    let _done=(${_progress}*4)/10
    let _left=40-$_done
    # Build progressbar string lengths
    _fill=$(printf "%${_done}s")
    _empty=$(printf "%${_left}s")
    printf "\rProgress : [${_fill// /\#}${_empty// /-}] ${_progress}%%"
}

function pTest(){
    ip="$1";
    dn="$2";
    md="$3";
    if [ -z $dn ]; then dn=$ip; fi;
    ping $ip -c 1 -w 4 &> /dev/null 
    if [ $? -ne 0 ]; then
        curl  $ip -k --max-time 5 &> /dev/null
        if [ $? -ne 0 ]; then ret="$dn curl and ping failed";
        else ret="$dn curl instead of ping passed"; fi;
    else
        ret="$dn ping passed";
    fi;
    
    if [ "$md" = "1" ]; then 
        # Decided to only bold failed and not success
        # ret=${ret//passed/**passed**}
        ret=${ret//failed/**failed**}
        ret="* $ret"
    fi;
    printf "${ret}"
}

function pTestFile(){
    IPLIST="$1"
    verbose="$2"
    markdown="$3"

    IFS=$'\n'
    total=`cat $IPLIST | wc -l`
    number=1

    for iprow in $(cat $IPLIST)
    do
        ip=$( echo "$iprow" |cut -d'|' -f2 );
        dn=$( echo "$iprow" |cut -d'|' -f1 );
        
        if [ "$verbose" = "1" ]; then result_line=$(pTest $ip $dn $markdown);
        else result_line=$(pTest $ip $dn);fi;
        
        result="$result$result_line\n"
        if [ "$verbose" = "1" ]; then ProgressBar ${number} ${total};
            let number=number+1;
        fi;
    done

    printf "\r                                                           \r"
    echo -e $result
    if [ "$verbose" = "1" ]; then echo "$total destinations tested..."; fi;
}


# PingTest Main
_verbose="0"
_markdown="0"
while [[ "$#" > 0 ]]; do
    case $1 in
        --help) 
            displayHelp; exit 0;;
        --version) 
            displayVersion; exit 0;;
        -f|--file) 
            _pingfile="$2";
            shift;;
        -v|--verbose) 
            _verbose="1"
            ;;
        -m|--markdown) 
            _markdown="1"
            ;;            
        -s|--server) 
            _pingserver="$2";
            shift;
            ;;
        *) echo "Unknown parameter passed: $1"; exit 1;;
    esac; 
    shift; 
done

if [ "$_verbose" = "1" ]; then 
    _title="pingtest ver $_version";
    if [ "$_markdown" = "1" ]; then _title="# $_title";
    else _title="$_title\n======================";
    fi;
    echo -e $_title
fi

if [ -n "$_pingserver" ]
then 
    echo -e $(pTest $_pingserver)
    exit 0
fi;

if [ -n "$_pingfile" ]; then pTestFile $_pingfile $_verbose $_markdown;exit 0; fi;



echo "Try pingtest --help for help";

## End ##
