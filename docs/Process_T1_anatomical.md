Processing the T1 anatomical
----------------------------

The standard location for T1 data is `/NHP_MRI/Data_proc/SUBJ/DATE/anat/T1`. An example script for running the below is at: `/NHP_MRI/Data_proc/EDDY/20170314/anat/T1/process_T1.sh` (more recent: [process-t1.sh](https://gist.github.com/williford/92d75962567404239574539104a2d1e1)).

### Pre-processing

If you are combining different types of T1's, use something like the following:

    #!/bin/bash
    
    set -e # exit if a command fails
    
    # --- First process the T1's individually
    FILES="T1_07.nii.gz
    T1_10.nii.gz
    T1_12.nii.gz"

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

### Using the BET command

Get the approximate middle coordinate (somewhere in the pons) and write them down (<x y z>)

    fslview T1_image &

JW: BET might work better a little higher up, like this:

![BET center](images/BET-skull-stripping-center_20170511.png)

Extract the brain using fsl’s BET routine (you may need to tweak the optional parameters a bit for the best result)

    bet inputfile outputfile(preferably ‘inputfile_brain’) -f 0.3 -c <x y z>

JW note: I find that `-f 0.55` works better for our data.

You can also use the gui:

    Bet &

### Performing Brain extraction with Freesurfer

Brain extraction sometimes works better with Freesurfer
    
    CK >> Add FS code here...

