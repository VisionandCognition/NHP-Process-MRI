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


[Processing the B0 fieldmap for undistortion](Processing_B0_fieldmap_for_undistortion.md)
-------------------------------------------

Run `process-fieldmaps.sh` or `process-fieldmaps.sh x y z`, where x,y,z are the center of the brain.
Calling without arguments will initiate the processing and then open the magnitude image with fslview (so you can find center).

For more details, visit [Processing the B0 fieldmap for undistortion](Processing_B0_fieldmap_for_undistortion.md).

[Processing functional data](Process_functional_data.md)
----------------------------

Information on processing the functional data has been moved to [Process functional data](Process_functional_data.md).
