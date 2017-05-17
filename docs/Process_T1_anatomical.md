Processing the T1 anatomical
----------------------------

The standard location for T1 data is `/NHP_MRI/Data_proc/SUBJ/DATE/anat/T1`. An example script for running the below is at: `/NHP_MRI/Data_proc/EDDY/20170314/anat/T1/process_T1.sh` (more recent: [process-t1.sh](https://gist.github.com/williford/92d75962567404239574539104a2d1e1)).

The information below is outdated.

Average multiple volumes using:

    mri_motion_correct.fsl -o outputfile -i inputfile1 -i inputfile2 etc

this might be equivalent to:

    mri_motion_correct2 -o outputfile -i inputfile1 -i inputfile2 etc

Correct for sphinx position and resample to iso voxels

    mri_convert -i inputfile -o outputfile --sphinx -vs  0.5 0.5 0.5

Correct display directions to match standards

    fslreorient2std inputfile  outputfile

Equalize contrast throughout

    mri_nu_correct.mni --i inputfile --o outputfile --distance 24  

Get the approximate middle coordinate (somewhere in the pons) and write them down (<x y z>)

    fslview T1_image &

Extract the brain using fsl’s BET routine (you may need to tweak the optional parameters a bit for the best result)

    bet inputfile outputfile(preferably ‘inputfile_brain’) -f 0.3 -c <x y z>

You can also use the gui:

    Bet &

Brain extraction sometimes works better with Freesurfer
    
    CK >> Add FS code here...

