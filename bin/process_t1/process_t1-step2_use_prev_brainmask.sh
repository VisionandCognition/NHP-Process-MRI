#!/bin/bash

# I usually end up creating a manual mask each time, regardless of whether I use BET or Freesurfer
# In this script, I just calculate the transformation from another T1 (with a hand-modified mask)
# to the current T1_avg_nu, and then apply that transformation to the hand-modified mask
flirt -ref T1_avg_nu.nii.gz -in /big/NHP_MRI/Data_proc/EDDY/20170608/anat/T1/T1_final -omat 0608_to_0614.mat -out test
flirt -ref /big/NHP_MRI/Data_proc/EDDY/20170608/anat/T1/T1_final_brain -in /big/NHP_MRI/Data_proc/EDDY/20170608/anat/T1/T1_final_brain -applyxfm -init 0608_to_0614.mat -out T1_final_brain
