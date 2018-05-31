Processing the T1 anatomical
----------------------------

The standard location for T1 data is `/NHP_MRI/Data_proc/SUBJECT/YYYYMMDD/anat/T1`. Example scripts are at: `/NHP_MRI/Data_proc/EDDY/20170614/anat/T1/process_t1-step*.sh`. Alternatively, after running the initial `minimal_processing` and `isotropic_resampling` steps with nipype in `NHP-BIDS` you can find them in `/NHP-MRI/NHP-BIDS/derivatives/resampled-isotropic-06mm/sub-<subject>/ses-<yyyymmdd>/anat`.

### Pre-processing the indivisual T1's

If you take the data from `Data_proc` they still need to be preprocessed. If you are combining different types of T1's, use something like the following:

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
    
    # --- Next, average together with motion correction
    mri_motion_correct.fsl -o T1_avg_nu.nii.gz \
        -i T1_10_nu.nii.gz -i T1_15_nu.nii.gz

Note that `N4BiasFieldCorrection` could be used instead of mri_nu_correct.mni, if mri_nu_correct.mni is difficult to get working on your system.

T1's that are already pre-processed in nipype, don't need to be re-oriented, but you might still want to perform the bias field correction.


### Brain extraction / skull-stripping

Brain extraction can be done several ways:

#### Using the BET command

Get the approximate middle coordinate (somewhere in the pons) and write them down (<x y z>)

    fslview T1_image &

JW: BET might work better a little higher up, like this:

![BET center](images/BET-skull-stripping-center_20170511.png)

Extract the brain using fsl’s BET routine (you may need to tweak the optional parameters a bit for the best result)

    bet inputfile outputfile(preferably ‘inputfile_brain’) -f 0.55 -c <x y z>

ME note:
* running ``bet`` with ``-R`` (robust option) gives generally favorable results
* tuning the ``-f`` parameter around the range ``f=0.11-0.9`` gives results that include the frontal pole (but also include some non-brain tissue anterior to the pons; in my experience that had no negative effect for the registration).

You can also use the gui:

    Bet &


#### Performing Brain extraction with Freesurfer

Brain extraction sometimes works better with Freesurfer

(JW) from 20170524/anat/T1/process_t1-step2_freesurfer.sh

    # -- Convert for freesurfer
    # Not performing crop, b/c it doesn't seem needed and I want to put back in the
    #   coordinates.
    mri_convert -i T1_avg_nu.nii.gz -o orig.mgz --in_orientation RAS -iis 1 -ijs 1 -iks 1

    # Should give different subjid for each run or delete existing folder (or not use the -i option below...)
    subjid=EDDY_20170524-2
    recon-all -i orig.mgz -subjid $subjid -autorecon1 -skullstrip -no-wsgcaatlas -wsthresh 15 -notal-check -notalairach -clean-bm -gcut

    # Lowering threshold will reduce the brain region, could be reduced further
    #recon-all -i orig.mgz -subjid $subjid -autorecon1 -no-wsgcaatlas -wsthresh 20 -notal-check -notalairach

    #recon-all -subjid $subjid -skullstrip -no-wsgcaatlas -wsthresh 15 -notal-check -notalairach -clean-bm -gcut

    # Copy file from freesurfer subject directory to current directory
    # will need to be modified, freesurfer must provide a better way to do this...
    cp /big/freesurfer-subjects/$subjid/mri/brainmask.mgz .

    # Return to original scale and coordinates
    mri_convert -i brainmask.mgz -o brainmask.nii.gz --out_orientation RAS -iis 0.5 -ijs 0.5 -iks 0.5

    # "-n" prevents overwritting (in my version)
    cp -n brainmask.nii.gz brainmask.manual.nii.gz

    # Convert into mask (0 or 255)
    fslmaths brainmask.manual.nii.gz -bin -mul 255 brainmask.manual.nii.gz

    # Edit with freeview
    freeview T1_avg_nu.nii.gz brainmask.manual.nii.gz:colormap=Heat:opacity=0.4


#### Using the NMT template as a prior

An alternative way to perform skullstripping, registration to template & atlas, and segmentation is by using the NIMH Macaque Template in `/NHP-MRI/Template/NMT/NMTv1.2`. 

Create a folder for your subject in `<>/NMTv1.2/single_subject_scans` and copy the`align_and_process.sh` script to it together with your (averaged) T1 image. Adjust the script to your needs (documentation in the script). and run it. 

This will:
- warp your T1 to the NMT template 
- provide non-linear warps for going back-and-forth in single-subject and template space
- warp the D99 atlas to your subject
- segment your T1, using the template segmentation as priors.
- skullstrip your T1

If for some reason the brainmask is off, you can now warp the template mask to single-subject space and apply it to create the skullstripped brain volume:

`fslmaths <Subject_BrainWithSkull.nii.gz> -mas <WarpedBrainMask.nii.gz> <Subject_Brain.nii.gz>
