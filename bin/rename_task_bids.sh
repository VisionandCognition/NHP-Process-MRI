#! /bin/bash

ROOT=/NHP_MRI/NHP-BIDS/

# rename tasks
declare -a typefld=(func)
for t in "${!typefld[@]}"; do
    find ${ROOT} -name *${t}*task-figureground* -exec bash -c 'mv "$1" "${1/task-figureground/task-figgnd}"' -- {} \;
done

# rename tasks
declare -a typefld=(func)
for t in "${!typefld[@]}"; do
    find ${ROOT} -name *${t}*task-figureground_localizer* -exec bash -c 'mv "$1" "${1/task-figureground_localizer/task-figgndloc}"' -- {} \;
done

# rename tasks
declare -a typefld=(func)
for t in "${!typefld[@]}"; do
    find ${ROOT} -name *${t}*task-restingstate* -exec bash -c 'mv "$1" "${1/task-restingstate/task-rest}"' -- {} \;
done