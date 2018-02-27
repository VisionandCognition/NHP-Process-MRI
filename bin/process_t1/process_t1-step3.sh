#!/bin/bash

set -e

if [ -e "brainmask.manual.nii.gz" ] && [ -e "T1_avg_nu_brain_mask-manual.nii.gz" ]
then
  echo "Cannot proceed with both brainmask.manual.nii.gz T1_avg_nu_brain_mask-manual.nii.gz."

  if cmp T1_avg_nu_brain_mask.nii.gz T1_avg_nu_brain_mask-manual.nii.gz > /dev/null 2>&1
  then
    echo "T1_avg_nu_brain_mask-manual.nii.gz doesn't seem to be modified and should be safe to delete (double check!)."
  fi
  exit 1
fi

if [ -e "brainmask.manual.nii.gz" ]; then
  brainmask=brainmask.manual.nii.gz
elif [ -e "T1_avg_nu_brain_mask-manual.nii.gz" ]; then
  brainmask=T1_avg_nu_brain_mask-manual.nii.gz
fi

ln -s T1_avg_nu.nii.gz T1_final.nii.gz
ln -s -f $brainmask T1_final_brain.nii.gz
