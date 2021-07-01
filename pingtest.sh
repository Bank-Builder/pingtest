#!/bin/bash
# Copyright (c) 2018, Andrew Turpin
# License MIT: https://opensource.org/licenses/MIT

_version="0.2"

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
 echo "    -e, --email     send an on-error notification email to [email@address] when using a pingtest list";
 echo "    -s, --server    pings a single server given in form [server-ip/url:port]";
 echo "    -v, --verbose   display vebose details and progress bar.  Works with -f option only.";
 echo "    -m, --markdown  formats the output in markdown.  Works with -v option only.";
 echo "    -q, --quiet     produces no terminal output, except setting bash return value \$? = 1 if failures found.";
 echo "        --settings  display SMTP settings and exits";
 echo "        --help      display this help and exit";
 echo "        --version   display version and exit";
 echo "";
 echo "  EXAMPLE(s):";
 echo "      pingtest -f [ipfile]";
 echo "      pingtest --server [server-ip/url:port]";
 echo "      pingtest -f [ipfile] --email support@domain.com -q";
 echo "";
}

function displayVersion(){
 echo "pingtest (bank-builder utils) version $_version";
 echo "Copyright (C) 2018-2021, Bank Builder";
 echo "License MIT: https://opensource.org/licenses/MIT";
 echo "";
}

function displaySMTPSettings(){
 echo "pingtest $_version SMTP settings";
 echo "================================================";
 echo "SMTP_SERVER="$SMTP_SERVER;
 echo "SMTP_TIMEOUT="$SMTP_TIMEOUT" (default is 15 seconds)";
 echo "SMTP_FROM_EMAIL="$SMTP_FROM_EMAIL;
 echo "SMTP_PORT="$SMTP_PORT;
 echo "SMTP_USERNAME="$SMTP_USERNAME;
 echo "SMTP_ENCRYPTION_METHOD="$SMTP_ENCTYPRION_METHOD" (Options are ENFORCE_TLS | TLS | NONE)";
#export SMTP_USEAUTHENTICATION=true
 echo "SMTP_USESSL="$SMTP_USESSL" (Default is true)";
 echo "SMTP_PASSWORD=";
 echo "SMTP_FROM_NAME="$SMTP_FROM_NAME;
 echo "================================================";
 echo "In order to use the --email option to send error notifications";
 echo "the environment variables above need to be correctly set.";
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

function sendEmail {
# $1 ToAddress
# $2 domainname of failed test
# Assumes environment variables
toAddress=$1
domain=$2
err=$(curl --max-time $SMTP_TIMEOUT --url 'smtp://'$SMTP_SERVER':'$SMTP_PORT --ssl-reqd   --mail-from $SMTP_FROM_EMAIL   --mail-rcpt $toAddress   --user $SMTP_USERNAME':'$SMTP_PASSWORD   -T <(echo -e 'From: '$SMTP_FROM_EMAIL'\nTo: '$toAddress'\nSubject: Pingtest Failure\n\n'$body) > /dev/null 2>&1 )
if [[ err -ne 0 ]]; then
    echo "Sending email failed"
fi

}

function pTest(){
    ip="$1";
    dn="$2";
    md="$3";
    if [[ -z $dn ]]; then dn=$ip; fi;
    ping $ip -c 1 -w 4 &> /dev/null 
    if [[ $? -ne 0 ]]; then
        curl  $ip -k --max-time 5 &> /dev/null
        if [[ $? -ne 0 ]]; then ret="$dn curl and ping failed";
        else ret="$dn curl instead of ping passed"; fi;
    else
        ret="$dn ping passed";
    fi;
    
    if [[ "$md" = "1" ]]; then 
        # Decided to only bold failed and not success
        # ret=${ret//passed/**passed**}
        ret=${ret//failed/**failed**}
        ret="* $ret"
    fi;
    echo $ret   
}

function pTestFile(){
    IPLIST="$1"
    verbose="$2"
    markdown="$3"
    sendto="$4"

    IFS=$'\n'
    total=`cat $IPLIST | wc -l`
    number=1
    result="\n"
    body=""
    for iprow in $(cat $IPLIST)
    do
        ip=$( echo "$iprow" |cut -d'|' -f2 );
        dn=$( echo "$iprow" |cut -d'|' -f1 );
        if [[ -z $dn ]]; then dn="$ip"; fi;

        if [[ "$markdown" == "1" ]]; then 
            result_line=$(pTest $ip $dn $markdown);
        else 
            result_line=$(pTest $ip $dn);
        fi;

        if [[ "$( echo $result_line |grep failed )" != "" ]]; then 
            if [[ "$sendto" != "NONE" ]]; then 
                body=$body"\nPing Test Failed to: "$dn;
            fi;
        fi;
        
        result="$result$result_line\n"
        if [[ "$verbose" == "1" ]]; then ProgressBar ${number} ${total};
            let number=number+1;
        fi;
        
    done
    if [[ "$body" != "" ]]; then 
        body="-----------------------\n"$body"\n\nRegards,\nPingtest ver "$_version"\n-----------------------\n"
        sendEmail ${sendto} ${body}
    fi    

    if [[ "$verbose" == "1" ]]; then result="$result\n$total destinations tested..."; fi;
   
}


# PingTest Main
_verbose="0"
_markdown="0"
_sendto="NONE"
_quiet="0"
while [[ "$#" > 0 ]]; do
    case $1 in
        --help) 
            displayHelp; exit 0;;
        --version) 
            displayVersion; exit 0;;
        --settings) 
            displaySMTPSettings; exit 0;;            
        -f|--file) 
            _pingfile="$2";
            shift;;
        -e|--email) 
            _sendto="$2";
            shift;;
        -s|--server) 
            _pingserver="$2";
            shift;
            ;;
        -v|--verbose) 
            _verbose="1";
            ;;
        -m|--markdown) 
            _markdown="1";
            ;;            
        -q|--quiet) 
            _quiet="1";
            ;;            
        *) echo "Unknown parameter passed: $1"; exit 1;;
    esac; 
    shift; 
done

if [[ "$_quiet" == "0" ]]; then 
    _title="pingtest ver $_version";
    if [[ "$_markdown" = "1" ]]; then _title="# $_title";
    else _title="$_title\n======================";
    fi;
    echo -e $_title
fi

if [[ -n "$_pingserver" ]]; then
    result=$(pTest $_pingserver)
    if [[ "$_quiet" == "0" ]]; then echo -e $result;fi;
    if [[ "$result" == *"failed"* ]]; then
        exit 1;  # failed
    else
        exit 0;  # OK    
    fi;
fi;

if [[ -n "$_pingfile" ]]; then 
    pTestFile ${_pingfile} ${_verbose} ${_markdown} ${_sendto}
    if [[ "$_quiet" == "0" ]]; then echo -e $result; fi;
    if [[ "$result" == *"failed"* ]]; then 
        exit 1;  # failed
    else
        exit 0;  # OK    
    fi;
fi;


echo "Try pingtest --help for help";

## End ##
