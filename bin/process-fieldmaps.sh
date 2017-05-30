#!/bin/bash

set -e

# phase and magnitude files
input_files="B0_phase.nii.gz
B0_mag.nii.gz"

for f in $input_files; do
  b=${f%.nii.gz}
  if [[ -f ${b}_ro.nii.gz ]]; then
    echo "Looks like $f has already been processed. Delete it if you want it regenerated."
  else
    echo "Reorienting $f"
    echo "mri_convert -i ${b}.nii.gz  -o ${b}_ro.nii.gz --sphinx -vs 1 1 1"
    mri_convert -i ${b}.nii.gz  -o ${b}_ro.nii.gz --sphinx -vs 1 1 1

    echo "fslreorient2std ${b}_ro.nii.gz ${b}_ro.nii.gz"
    fslreorient2std ${b}_ro.nii.gz ${b}_ro.nii.gz
  fi
done

if [[ "$#" -ne 3 ]]; then
  fslview ${b}_ro.nii.gz &
  echo "Give the center position of the brain, using ${b}_ro.nii.gz!"
  echo
  echo "Syntax:"
  echo "    $0 x y z"
  echo
  exit 1
fi

echo "$0 $@" > ran_process-fieldmaps.sh

# http://www.spinozacentre.nl/wiki/index.php/NeuroWiki:Current_developments#B0_correction

# fugue needs units to be rad/s instead of Hz
# convert from -100 to 100 to -pi to pi
fslmaths B0_phase_ro.nii.gz -mul 3.141592653589793116 -div 100 B0_phase_rad -odt float

# convert from -100 to 100 to 0 to 2*pi
#fslmaths B0_phase_ro.nii.gz -add 100 -mul 3.141592653589793116 -div 100 B0_phase_rad -odt float

# Create skull-stripped mask
bet B0_mag_ro B0_mag_ro_brain -f 0.55 -g -0.1 -c 49 50 38
fslmaths B0_mag_ro_brain -dilM B0_mag_ro_brain_mask

echo "Running prelude"
prelude -a B0_mag_ro.nii.gz -p B0_phase_rad.nii.gz -o B0_phase_unwrap.nii.gz -m B0_mag_ro_brain_mask.nii.gz

# Convert to radians/sec, 5 ms between scans: 200 * 5 ms = 1 s
fslmaths B0_phase_unwrap.nii.gz -mul 200 B0_phase_unwrap.nii.gz
