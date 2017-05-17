Processing steps used in NHP fMRI
=================================

Code repository
---------------
Reusable code is put in the Process-NHP-MRI repository, which is at:

* https://github.com/VisionandCognition/Process-NHP-MRI

This repository includes the `process_nhp_mri` Python package. To be able
to use, you should include the python directory in your PYTHONPATH:

    export PYTHONPATH=$PYTHONPATH:/PATH/TO/Process-NHP-MRI/python

This is necessary for some of the scripts in the NHP_MRI Data_proc directory.

Some of the python scripts that should not be included are in the
`Process-NHP-MRI/bin` directory. You should add this to your $PATH.


Download data from XNAT
-----------------------

I've (JW) been downloading the XNAT data to (for example) `/NHP_MRI/Data_raw/EDDY/20170420/MRI/xnat`.


Convert dicom to nifti
----------------------

If you download the data from the XNAT server, you can run:

    process_xnat_dicoms.py xnat [NII]

where `xnat` is the XNAT downloaded directory and `NII` is the nifti output directory. If your current directory has the directory `xnat` all of the parameters are optional. This function uses `dcm2niix`. It uses the gzip command for compression, since the `dcm2nii` had difficulty handling compression of large files (I haven't tested dcm2niix).

Use dcm2nii or dcm2niix in the terminal, e.g.:

    dcm2nii -o outputfolder dicomfolder/*

Copying the data from Data_raw to Data_proc
-------------------------------------------

I have an example script of this at `/NHP_MRI/Data_raw/EDDY/20170420/copy-to-proc.sh`.


[Processing the T1 anatomical](Process_T1_anatomical.md)
----------------------------

Moved to [Processing T1 anatomical](Process_T1_anatomical.md).


Processing the B0 fieldmap for undistortion
-------------------------------------------

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


[Processing functional data](Process_functional_data.md)
==========================

Information on processing the functional data has been moved to [Process functional data](Process_functional_data.md).
