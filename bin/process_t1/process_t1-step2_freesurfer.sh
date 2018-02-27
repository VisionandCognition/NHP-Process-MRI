#!/bin/bash

set -e # exit as soon as one of the command fails

# -- Convert for freesurfer
# Not performing crop, b/c it doesn't seem needed and I want to put back in the
#   coordinates.
mri_convert -i T1_avg_nu.nii.gz -o orig.mgz --in_orientation RAS -iis 1 -ijs 1 -iks 1

# Should give different subjid for each run or delete existing folder (or not use the -i option below...)
subjid=EDDY_20170608-T1
recon-all -i orig.mgz -subjid $subjid -autorecon1 -skullstrip -no-wsgcaatlas -wsthresh 15 -notal-check -notalairach -clean-bm -gcut

# Lowering threshold will reduce the brain region, could be reduced further
#recon-all -i orig.mgz -subjid $subjid -autorecon1 -no-wsgcaatlas -wsthresh 20 -notal-check -notalairach

#recon-all -subjid $subjid -skullstrip -no-wsgcaatlas -wsthresh 15 -notal-check -notalairach -clean-bm -gcut

# Copy file from freesurfer subject directory to current directory
# will need to be modified, freesurfer must provide a better way to do this...
cp /big/freesurfer-subjects/$subjid/mri/brainmask.mgz .

# Return to original scale and coordinates
mri_convert -i brainmask.mgz -o brainmask.nii.gz --out_orientation RAS -iis 0.5 -ijs 0.5 -iks 0.5

# "-n" prevents overwritting
cp -n brainmask.nii.gz brainmask.manual.nii.gz

# cropsize should match dimensions of fslinfo T1_avg_nu.nii.gz
mri_convert -i brainmask.manual.nii.gz --cropsize 180 180 121 -o brainmask.manual-test.nii.gz -nc

# Convert into mask (0 or 255)
fslmaths brainmask.manual.nii.gz -bin -mul 255 brainmask.manual.nii.gz

# Edit with freeview
freeview T1_avg_nu.nii.gz brainmask.manual.nii.gz:colormap=Heat:opacity=0.4
