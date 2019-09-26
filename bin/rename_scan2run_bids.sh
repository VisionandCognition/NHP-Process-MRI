#! /bin/bash

ROOT=/NHP_MRI/NHP-BIDS/

# replace scan with run in anat/fmap/dwi folders
declare -a typefld=(anat fmap dwi)
for t in "${!typefld[@]}"; do
    find ${ROOT} -name *${t}*scan* -type f -exec bash -c 'mv "$1" "${1/scan/run}"' -- {} \;
done
