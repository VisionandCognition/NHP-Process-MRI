Processing steps used in NHP fMRI
=================================

Code repository
---------------
Reusable code is put in the Process-NHP-MRI repository, which is at:

* https://github.com/VisionandCognition/Process-NHP-MRI

This repository include the process_nhp_mri Python package. To be able
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


Processing the T1 anatomical
----------------------------

Average multiple volumes using:

    mri_motion_correct.fsl -o outputfile -i inputfile1 -i inputfile2 etc
    
or

    mri_convert -o outputfile -i inputfile1 -i inputfile2 etc

Correct for sphinx position and resample to iso voxels

    mri_convert -i inputfile -o outputfile --sphinx -vs 1 1 1

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


Preprocessing functionals
-------------------------

all_preprocess.py
This scripts performs some standard pre-processing tasks. It calls some other scripts that are located in the ‘subscripts’ folder:

    re_orient_functs.py
	
Looks for functional runs in a particular location (see script).
Re-orients from sphynx orientation and creates 1 mm isotropic voxels

    mri_convert -i inputfile -o outputfile --sphinx -vs 1 1 1

Correct display directions to match standards

    fslreorient2std inputfile  outputfile
    get_motion_outliers.py
	
This takes the functional runs, looks for motion outliers and creates a mask (in a text file that allows excluding these outlier volumes from the GLM later.
It also creates fsl-output in a html file in the QA folder.
Loops over runs.

The relevant function to detect outliers is:
 
    fsl_motion_outliers -i inputfile -o outputfile --dvars -p outputplot -v

the --dvars indicates detection based on on intensity fluctuations, you can also use --fd for a frame-wise displacement criterion.


Processing the functionals
--------------------------

The first run may be done manually to see if everything works as expected and to create a template fsl-settings file (fsf-file). This can then be used to do all other runs in a batch.

Start the fsl feat gui

    Feat &

### Data ###

Select your pre-processed functional data as 4D data and rename the default output directory
Total volumes and TR should be automatically detect (but check!)
Do not delete any volumes from the start. The dummy scans aren’t saved and we model the planned pre-experimental volumes as they are defined in the runstim.
High pass filter to match design

### Pre-stats settings ###
MCFLIRT motion corrections
BET brain extraction
Smooth as desired (we originally had 1.25 mm voxels and resampled to 1 mm, so I wouldn’t go much higher than 2 mm here)
High pass temporal filtering
Include a MELODIC ICA if that’s relevant for your question (will take longer to process)

### Registration settings ###

Main structural >> the high-res T1
You may need to check what registration method works best but here. BBR doesn’t always work great for monkeys.
Standard space >> a template, e.g. the D99_template.nii.gz (Saleem & Logothetis atlas)
I’d go with 12 DOF here, but you can try nonlinear as well (takes longer and may give weird result, so always check your registrations)

### Stats ###

Use FILM
Add Standard Motion Parameters
Add additional confound Evs >> your motion_outliers filename
Full model setup for a GLM
For each EV (‘explanatory variable’) link a 3 column text file with the model (column 1: time of event, column 2: duration of event, column 3: value, choose 1 if this isn’t parametrically varied).
I save these text files in the folder ‘model’. The stimulus is of course most important, but I also wrote some matlab scripts to create them for behavioral and eye parameters.
Convolve the EV’s with a double gamma HRF			
Use the Contrast & F-tests tab to set the EV(s) of interest

### Post-stats ###
This may not be so interesting for a single run, but you may want to check it anyway.
Choose if you want to do visualize on voxel or cluster base.


 Processing the functionals: BATCH
 ---------------------------------

Running FSL Feat manually creates a design.fsf file that we can use as a template for batch processing (can also be created by choosing ‘save’ in the gui). Copy it (I use a folder fsf_lev1 in scripts where I save it as design_template.fsf)

Edit this file with wildcards so we can use to create run-specific design files (I use ‘NTPTS’ where the number of volumes is defined, ‘RUNNUM’ where the run-number is mentioned)

make_fsf_designs.py
uses the template to create run_specific design files. Replaces the wildcards and saves design files in the ‘lev1’ folder

run_all_fsf_lev1.py
uses the new design files and runs feats for all runs.


Check the result of the processed functionals
---------------------------------------------

The script QA_all_lev1s.py checks all results and puts it in QA/lev1
