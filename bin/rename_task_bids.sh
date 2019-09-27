#! /bin/bash

ROOT=/NHP_MRI/NHP-BIDS/

# rename tasks

# figure ground
declare -a typefld=(func)
for t in "${!typefld[@]}"; do
    find ${ROOT} -type d -name *${t}*task-figureground* -exec bash -c 'mv "$1" "${1/task-figureground/task-figgnd}"' -- {} \;
done

declare -a typefld=(func)
for t in "${!typefld[@]}"; do
    find ${ROOT} -type f -name *${t}*task-figureground* -exec bash -c 'mv "$1" "${1/task-figureground/task-figgnd}"' -- {} \;
done

# figure ground localizers
declare -a typefld=(func)
for t in "${!typefld[@]}"; do
    find ${ROOT} -type d -name *${t}*task-figgnd_localizer* -exec bash -c 'mv "$1" "${1/task-figgnd_localizer/task-figgndloc}"' -- {} \;
done

declare -a typefld=(func)
for t in "${!typefld[@]}"; do
    find ${ROOT} -type f -name *${t}*task-figgnd_localizer* -exec bash -c 'mv "$1" "${1/task-figgnd_localizer/task-figgndloc}"' -- {} \;
done

# resting state
declare -a typefld=(func)
for t in "${!typefld[@]}"; do
    find ${ROOT} -type d -name *${t}*task-restingstate* -exec bash -c 'mv "$1" "${1/task-restingstate/task-rest}"' -- {} \;
done

declare -a typefld=(func)
for t in "${!typefld[@]}"; do
    find ${ROOT} -type f -name *${t}*task-restingstate* -exec bash -c 'mv "$1" "${1/task-restingstate/task-rest}"' -- {} \;
done