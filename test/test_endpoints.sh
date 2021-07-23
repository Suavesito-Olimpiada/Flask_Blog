#!/usr/bin/env bash

declare -A C    # Colors
C[W]="\033[0m"  # White
C[R]="\033[31;1m" # Red
C[G]="\033[32;1m" # Green
C[B]="\033[34;1m" # Blue

function generate_credential()
{
    USER=`tr -dc A-Za-z0-9 </dev/urandom | head -c 13`
    PASSWD=`tr -dc A-Za-z0-9 </dev/urandom | head -c 13`
    printf "username=$USER&password=$PASSWD\n"
}

function head_status()
{
    sed -n '1p' $@ | cut -d' ' -f2
}

function get_status()
{
    curl -I -s "$@" | head_status
}

function post_status()
{
    curl -s -D - -X POST -d "$2" "$1" | head_status
}

function test_endpoints()
{
    URL="$1"
    ENDP="$2"
    if [[ "$3" == "GET" ]]
    then
        GET="$3"
    else
        GET=""
    fi
    if [[ "$4" == "POST" ]]
    then
        POST="$4"
        CREDS="$5"
    else
        POST=""
        CREDS=""
    fi

    printf "${C[B]}URL:${C[W]} $URL\n"
    printf "${C[B]}ENDP:${C[W]} $ENDP\n"

    [[ -z "$GET" ]] || GET_STATUS=`get_status "$URL$ENDP"`
    [[ -z "$POST" ]] || POST_STATUS=`post_status "$URL/$ENDP" "$CREDS"`

    if [[ -n "$GET" ]]
    then
        printf "${C[B]}GET:${C[W]} $GET_STATUS "
        if [[ $GET_STATUS == 200 ]]
        then
            printf "(${C[G]}sucess${C[W]})\n"
        else
            printf "(${C[R]}fail${C[W]})\n"
        fi
    fi

    if [[ -n "$POST" ]]
    then
        printf "${C[B]}POST:${C[W]} $POST_STATUS "
        if [[ $POST_STATUS == 200 ]] || [[ $POST_STATUS == 301 ]] || [[ $POST_STATUS == 303 ]]
        then
            printf "(${C[G]}sucess${C[W]})"
        else
            printf "(${C[R]}fail${C[W]})"
        fi
        printf "; with CREDENTIALS=\"$CREDS\"\n"
    fi
}

CREDENTIALS=`generate_credential`
MOCK_CREDENTIALS="username=user&password=password"

URL='https://suavesito.duckdns.org'
ENDPOINTS="\
/:GET:-:$CREDENTIALS
/jose:GET:-:$CREDENTIALS
/reem:GET:-:$CREDENTIALS
/nandini:GET:-:$CREDENTIALS
/health:GET:-:$CREDENTIALS
/register:GET:POST:$CREDENTIALS
/register:GET:POST:$CREDENTIALS
/login:GET:POST:$CREDENTIALS
/login:-:POST:$MOCK_CREDENTIALS
/random:GET:POST:$MOCK_CREDENTIALS
"

printf "$ENDPOINTS" | while read ENDP
do
    test_endpoints "$URL" `printf "$ENDP" | tr ':' ' '`
    echo
done

