#!/bin/bash

function displayHelp(){
 echo "Usage pingtest [OPTION]... [FILE]";
 echo "   Tries to ping a list of ip's or url's provided in a file or at command line";
 echo "   and if ICMP packets are blocked (ping fails) the program will attempt";
 echo "   to connect via http/s at the port specified";
 echo " ";
 echo "  OPTIONS:";
 echo "    -d, --delpoy    the file to deploy";
 echo "    -f, --file      supply file name with ip's or urls to test";
 echo "                    the file format is [server-display-name] | ip/url:port and";
 echo "                    if ping is blocked (e.g. AWS) then the test will try curl. ";
 echo "    -s, --server    www.my-aws-server.com:8443";
 echo "        --help      display this help and exit";
 echo "        --version   display version and exit";
 echo "";
 echo "  EXAMPLE:";
 echo "      pingtest -f [ipfile] -u true";
 echo "";
}

function displayVersion(){
 echo "pingtest (bank-builder utils) version 1.01";
 echo "Copyright (C) 2018, Andrew Turpin";
 echo "License MIT: < https://opensource.org/licenses/MIT >.";
 echo "";
}

function pTest(){
    ip="$1"
    dn="$2"
    if [ $dn"" = "" ]; then dn=$ip; fi;
    ping $ip -c 1 -w 4 &> /dev/null 
    if [ $? -ne 0 ]; then
        curl  $ip -k --max-time 5 &> /dev/null ;
        if [ $? -ne 0 ]; then
            echo *$dn curl and ping failed*;
        else
            echo $dn curl instead of ping passed;
        fi
        else

        echo $dn ping passed;
    fi
}

function pTestFile(){
IPLIST="$1"
IFS=$'\n'
x=`cat $IPLIST | wc -l`
for iprow in $(cat $IPLIST)

do
    ip=$( echo "$iprow" |cut -d'|' -f2 );
    dn=$( echo "$iprow" |cut -d'|' -f1 );
    pTest $ip $dn;
done

echo $x destinations tested...
}


# Main 
help=0;
ver=0;
while [[ "$#" > 0 ]]; do 
    case $1 in
        -f|--file) 
            pTestFile $2;
            exit 0;
            shift;;
         -s|--server) 
            pTest $2;
            exit 0;
            shift;;
        --help) 
            displayHelp; exit 0;;
        --version) 
            displayVersion; exit 0;;
        *) echo "Unknown parameter passed: $1"; exit 1;;
    esac; 
    shift; 
done

echo "Try pingtest --help for help";

## End ##
