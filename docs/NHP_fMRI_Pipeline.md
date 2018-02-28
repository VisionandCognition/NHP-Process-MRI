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

Go to the subject's directory, ex. /NHP_MRI/Data_raw/EDDY, and type:

    SCAN_DATE=20171231  # <- Scan session date
    SUBJ=EDDY  # SUBJECT
    # workon mri-py2  # <-- requires Python 2 and pyxnat
    pmri_setup_raw_dir ${SCAN_DATE}
    cd $SCAN_DATE
    download_xnat NHP_${SCAN_DATE}_${SUBJ}
    
If successful, it will state "Succesfully contacted XNAT. Downloading now...". If not successful, it will hang for a long time. The first time you run download_xnat, it will create an credientials file. You will need to delete or modify this credientials file if you change your password.

I've (JW) been downloading the XNAT data to (for example) `/NHP_MRI/Data_raw/EDDY/20170420/MRI/xnat`.


Convert dicom to nifti
----------------------

Note that the SCNAT's conversion to Nifti doesn't generate BIDS json files. You may want to run `process_xnat_dicoms.py` or `dcm2niix` to generate these files (may be necessary for publishing data?).

If the XNAT server already performed the nifti conversion, you may want to move these to a separate directory:

    mkdir MRI/NII
    find MRI -name "*.nii.gz" -exec mv {} MRI/NII \;

If you download the data from the XNAT server, but the Nifti conversion has not been run (or has run with errors), you can run:

    process_xnat_dicoms.py xnat [NII]

where `xnat` is the XNAT downloaded directory and `NII` is the nifti output directory. If your current directory has the directory `xnat` all of the parameters are optional. This function uses `dcm2niix`. It uses the gzip command for compression, since the `dcm2nii` had difficulty handling compression of large files (I haven't tested dcm2niix).

Use dcm2nii or dcm2niix in the terminal, e.g.:

    dcm2nii -o outputfolder dicomfolder/*
    
Copying behavioral data
-----------------------

To move Behavior data from USB, try something like:

    find /media/jonathan/0A1E-0594/Data/ -name "Eddy_*StimSettings*${SCAN_DATE}*.[0-9][0-9]" -exec mv {} Behavior \;

And for the eye data:

     find /media/jonathan/0A1E-0594/Data/ -name "Eddy_${SCAN_DATE}*.tda" -exec mv {} Eye \;

Copying the data from Data_raw to Data_proc (or BIDS directory)
-------------------------------------------

I have an example script of this at `/NHP_MRI/Data_raw/EDDY/20170420/copy-to-proc.sh`.

For the curve tracing, I've started copying Data_raw to BIDS_raw. You can find examples with the following from `Data_raw` or the subject's directory:

    find -maxdepth 3 -name "copy-to-bids.sh" -exec ls -lt {} +

For more on processing BIDS pipeline, see: [BIDS_Processing](BIDS_processing.md).

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

Note: A lot of the this information has been replaced by the [BIDS_processing pipeline](BIDS_processing.md).

Information on processing the functional data has been moved to [Process functional data](Process_functional_data.md).
