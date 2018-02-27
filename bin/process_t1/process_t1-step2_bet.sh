#!/bin/bash

set -e # exit as soon as one of the command fails

bet  T1_avg_nu.nii.gz T1_avg_nu_brain-55.nii.gz -m -f 0.55 -c 89 81 79
bet  T1_avg_nu.nii.gz T1_avg_nu_brain-45.nii.gz -m -f 0.45 -c 89 81 79
bet  T1_avg_nu.nii.gz T1_avg_nu_brain-35.nii.gz -m -f 0.35 -c 89 81 79
bet  T1_avg_nu.nii.gz T1_avg_nu_brain-25.nii.gz -m -f 0.25 -c 89 81 79
bet  T1_avg_nu.nii.gz T1_avg_nu_brain-15.nii.gz -m -f 0.15 -c 89 81 79

# Create manual mask (but don't overwrite)
cp -n T1_avg_nu_brain_mask.nii.gz T1_avg_nu_brain_mask-manual.nii.gz

# Manually edit mask using:
freeview T1_avg_nu.nii.gz T1_avg_nu_brain_mask-manual.nii.gz

# apply manually edited brain mask
# fslmaths contrast_equalized.nii.gz -mas contrast_equalized_brain_mask-manual.nii.gz contrast_equalized_brain.nii.gz

