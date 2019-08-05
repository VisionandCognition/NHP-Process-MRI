#! /bin/bash

SERVER=/media/NETDISKS/VS02/VandC
#SERVER=/media/DATA1
#SERVER=/media/chris/MRI_3

RAWDATA=${SERVER}/NHP_MRI/Data_raw

if [ $# -eq 0 ]; then
    echo 'No arguments given. Assuming you want json files silenced.'
    echo 'For more control give input 1 for silence, 0 for unsilence.'
    ON=1
else
    if [ $1 -eq 0 ]; then
        echo 'Unsilencing json files in Data_raw for indexing.'
        echo 'Removing _noindex from extension.'
        ON=${1}
    elif [ $1 -eq 1 ]; then
        echo 'Silencing json files in Data_raw for indexing.'
        echo 'Adding _noindex to extension.'
        ON=${1}
    else
        echo 'Wrong argument given. Can only be 1 (silence) or 0 (unsilence)'
        exit 1
    fi
fi

if [ $ON -eq 1 ]; then
    find ${RAWDATA} -name '*session.json' -type f -exec bash -c 'mv "$1" "${1}_noindex"' -- {} \;
elif [ $ON -eq 0 ]; then
    find ~/Desktop -name '*session.json_noindex' -type f -exec bash -c 'mv "$1" "${1/_noindex/}"' -- {} \;
fi

