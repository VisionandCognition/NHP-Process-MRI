Processing steps used in NHP fMRI
=================================

**NB! Most of this has been superceded by BIDS-based analysis pipelines    
(see https://github.com/VisionandCognition/NHP-BIDS)**

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


Download data from the Scanner
------------------------------

There are different ways of doing this. Files form our scanning sessions are generally automatically pushed to the Spinoza Centre's XNAT server. Below, you can find an explanation of how to get it off this server and on your local machine, but note that this process is not always superreliable. Alternatively, we tend to copy our data to the `FTP/projects` folder on the MRI console manually and than download it from the SC-FTP server with an FTP-client like Filezilla (linux) or Cyberduck (mac). However you do it, you should end up with a DICOM folder in `/NHP_MRI/Data_dcm/<SUBJ>/<YYYYMMDD>`

== From the XNAT server ===    
Go to the subject's directory, ex. /NHP_MRI/Data_raw/EDDY, and type:

    SCAN_DATE=20171231  # <- Scan session date
    SUBJ=EDDY  # SUBJECT
    # workon mri-py2  # <-- requires Python 2 and pyxnat
    pmri_setup_raw_dir ${SCAN_DATE}
    cd $SCAN_DATE
    download_xnat NHP_${SCAN_DATE}_${SUBJ}
    
If successful, it will state "Succesfully contacted XNAT. Downloading now...". If not successful, it will hang for a long time. The first time you run download_xnat, it will create an credientials file. You will need to delete or modify this credentials file if you change your password.

The XNAT server is a service of the Spinoza Center that tends to be under development. At this moment (2018-05-31) it is operational and the fastest way to get the data from it is probably by downloading a large zip-file from the web-interface. SC management is considering implementing another solution so all this may change in the future.

At any rate, you should be able to get the data from the SC as soon as possible and *check whether it is complete and non-corrupt*. Then,save the dicoms in `VCNIN/Data_dcm/<SUBJECT>/<YYYYMMDD>`.

Convert dicom to nifti
----------------------

Note that the SCXNAT's conversion to Nifti doesn't generate BIDS json files. It is therefore better to download the dicom files and do the conversion ourselves. To do this, you can run `process_xnat_dicoms.py` or `dcm2niix` to generate nifti files.

If the XNAT server already performed the nifti conversion, you may want to move these to a separate directory:

    mkdir MRI/NII
    find MRI -name "*.nii.gz" -exec mv {} MRI/NII \;

If you download the data from the XNAT server, but the Nifti conversion has not been run (or has run with errors), you can run:

    process_xnat_dicoms.py xnat [NII]

where `xnat` is the XNAT downloaded directory and `NII` is the nifti output directory. If your current directory has the directory `xnat` all of the parameters are optional. This function uses `dcm2niix`. It uses the gzip command for compression, since the `dcm2nii` had difficulty handling compression of large files. The boxcar flag (`-b`) can be used to also create json files with information from the dicom headers. This can be very useful when you need to match up behavioral logs with functional data (use the 'acquisition time' mentioned in the json and compare with the timestamp in the log-filenames). To enable the json output use `-b y`, if you want to get only the json files you can use `-b o` (but since this takes some time, it is a lot faster to already include the operation on the first conversion).

Use dcm2niix in the terminal, e.g.:

    dcm2niix -b y -o outputfolder dicomfolder/*

THe latest versions of `dcm2niix` is a bit picky about data consistency and doesn't do well with some of our standard output dicoms. If you first remove all dicom files that start with `XX` you should not run into errors.

Raw copies of the nifti files need to be saved in `VCNIN/Data_raw/SUBJECT/YYYYMMDD/MRI/`. We will also keep raw versions of the behavioral logs and eye-data here. Any processing will be done in `VCNIN/NHP-BIDS/` (preferred) or `VCNIN/Data_proc`.
    
Copying behavioral data
-----------------------

To move Behavior data from USB, try something like:

    find /media/usb-drive/Data/ -name "Eddy_*StimSettings*${SCAN_DATE}*.[0-9][0-9]" -exec mv {} Behavior \;

And for the eye data:

     find /media/usb-drive/Data/ -name "Eddy_${SCAN_DATE}*.tda" -exec mv {} Eye \;

Copying the data from Data_raw to BIDS directory or Data_proc
-------------------------------------------------------------

There are example scripts for this at `/NHP_MRI/Scripts/copy-to-bids.sh` and `/NHP_MRI/Scripts/copy-to-proc.sh`.

You can find more recent examples with the following from `Data_raw` or the subject's directory:

    find -maxdepth 3 -name "copy-to-bids.sh" -exec ls -lt {} +

For more on processing BIDS pipeline, see: [NHP-BIDS_Processing](NHP-BIDS_processing.md).

[Processing the T1 anatomical](Process_T1_anatomical.md)
------------------------------

Moved to [Processing T1 anatomical](Process_T1_anatomical.md).


[Processing the B0 fieldmap for undistortion](Processing_B0_fieldmap_for_undistortion.md)
---------------------------------------------

Run `process-fieldmaps.sh` or `process-fieldmaps.sh x y z`, where x,y,z are the center of the brain.
Calling without arguments will initiate the processing and then open the magnitude image with fslview (so you can find center).

For more details, visit [Processing the B0 fieldmap for undistortion](Processing_B0_fieldmap_for_undistortion.md).

[Processing functional data](Process_functional_data.md)
----------------------------

Note: A lot of the this information has been replaced by the [BIDS_processing pipeline](BIDS_processing.md).

Information on processing the functional data has been moved to https://github.com/VisionandCognition/NHP-BIDS.
