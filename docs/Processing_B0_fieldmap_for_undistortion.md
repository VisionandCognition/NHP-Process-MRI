Run `process-fieldmaps.sh` (from bin directory) or `process-fieldmaps.sh x y z`, where x,y,z are the center of the brain.
Calling without arguments will initiate the processing and then open the magnitude image with fslview (so you can find center).

Details
-------

Reorient the magnitude/phase images

    mri_convert -i XXX.nii.gz  -o XXX_ro.nii.gz --sphinx -vs 1 1 1
    fslreorient2std -i XXX_ro.nii.gz -o XXX_ro.nii.gz 

Convert phase image to radians (Philips scales from -100 to 100)
 
    fslmaths B0_phase_ro.nii.gz -mul 3.141592653589793116 -div 100 B0_phase_rad -odt float

Skullstrip the magnitude volume (you may need to adjust parameters, and find center x,y,z)

    bet B0_mag_ro B0_mag_ro_brain  -f 0.35 -g -0.1 -c x y z

Create a brain mask

    fslmaths B0_mag_ro_brain -dilM B0_mag_ro_brain_mask

Unwrap the phase image with PRELUDE and mask with brain

    prelude -a B0_mag_ro.nii.gz -p B0_phase_rad.nii.gz -o B0_phase_unwrap.nii.gz -m B0_mag_ro_brain_mask.nii.gz

Convert to radials-per-second by multiplying with 200 (delta TE is 5 msec >> check if you didn't use the standard B0 sequence).

    fslmaths B0_phase_unwrap.nii.gz -mul 200 B0_phase_unwrap.nii.gz

This gives you the files that you later include in the FSL pre-processing tab fo perform fieldmap correction
