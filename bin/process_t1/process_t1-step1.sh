#!/bin/bash

set -e # exit as soon as one of the command fails

# Bad T1's:
#   * T1_SENSE_04.nii.gz - doesn't seem very aligned with NO-SENSE T1's

# --- First process the T1's individually
FILES="
T1_10.nii.gz
T1_15.nii.gz
"

preprocess_indiv () {
  local f=$1
  b=${f%.nii.gz}
  mri_convert -i ${b}.nii.gz -o ${b}_ro.nii.gz --sphinx -vs 0.5 0.5 0.5
  fslreorient2std ${b}_ro.nii.gz ${b}_ro.nii.gz
  mri_nu_correct.mni --i ${b}_ro.nii.gz --o ${b}_nu.nii.gz --distance 24
}

for f in $FILES; do
  preprocess_indiv $f &
done

wait # wait for individual file preprocessing

# --- Next, average together with motion correction
mri_motion_correct.fsl -o T1_avg_nu.nii.gz \
  -i T1_10_nu.nii.gz -i T1_15_nu.nii.gz

# --- Find center point using freeview or fslview, if you are using BET

# freeview T1_avg_nu.nii.gz
