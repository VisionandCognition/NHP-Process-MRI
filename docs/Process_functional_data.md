Preprocessing functionals
-------------------------

You can run the command `preprocess_functionals.py` from the session directory (the directory with the `run00x`). This works the same as `all_preprocess.py`. If this runs correctly, you can continue to the next section, "Processing the functionals".

### all_preprocess.py
This scripts performs some standard pre-processing tasks. It calls some other scripts that are located in the ‘subscripts’ folder (also in this repository, in process_nhp_mri package):

#### re_orient_functs.py
	
Looks for functional runs in a particular location (see script).
Re-orients from sphynx orientation and creates 1 mm isotropic voxels

    mri_convert -i inputfile -o outputfile --sphinx -vs 1 1 1

Correct display directions to match standards

    fslreorient2std inputfile  outputfile
    
#### get_motion_outliers.py
	
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

### Data

Select your pre-processed functional data as 4D data ("fois.nii.gz") and rename the default output directory (e.g. "run00x/fsl_lev1/manual").
Total volumes and TR should be automatically detected (but check!)
Do not delete any volumes from the start. The dummy scans aren’t saved and we model the planned pre-experimental volumes as they are defined in the runstim.
High pass filter to match design.

### Pre-stats settings

* Motion correction: MCFLIRT
* B0 unwarping [✔]
  * Fieldmap = the unwarped phase volume (B0_phase_unwrap.nii.gz)
  * Fieldmap mag = the brain extracted magnitude volume (B0_mag_ro_brain.nii.gz)
  * Effective EPI echo spacing = 0.5585 
    * This is based on Diederik’s formula: EEES =  ((1000 * wfs)/(434.215 * (EPI factor+1))/acceleration)
    * with wfs (water fat shift) = 17.462; EPI factor = 35; acceleration (SENSE) = 2 (check sequence!)
  * EPI TE = 20 ms
  * Unwarp direction = y or  -y (try both)
    * Should be y if you scaled from -\pi to \pi (Diederick's example script)
    * -y if you scaled from 0 to  2 \pi
  * % signal loss threshold = 10
  
* BET brain extraction [✔]
* Smooth as desired (we originally had 1.25 mm voxels and resampled to 1 mm, so I wouldn’t go much higher than 2 mm here)
* High pass temporal filtering [✔]
* Include a MELODIC ICA if that’s relevant for your question (will take longer to process)

### Registration settings ###

* Main structural: the high-res T1 (e.g. "YYYYMMDD/anat/T1/T1_skull-stripped.nii.gz")
* You may need to check what registration method works best but here. BBR doesn’t always work great for monkeys (although it is required when using B0 unwarping).
* Standard space: a template, e.g. the D99_template.nii.gz (Saleem & Logothetis atlas)
  * I’d go with 12 DOF here, but you can try nonlinear as well (takes longer and may give weird result, so always check your registrations)

### Stats

* Use FILM
* Add Standard Motion Parameters
* Add additional confound Evs = your motion_outliers filename (e.g. "run00x/funct/motion_assess/confound.txt")
* Full model setup for a GLM

#### Process Behavior data / Create model

For curve tracing, there is `calc_curvetracing_time_events.py` in the "bin" of this repository. This does not analyze the Eye traces.

For each EV (‘explanatory variable’) link a 3 column text file with the model (column 1: time of event, column 2: duration of event, column 3: value, choose 1 if this isn’t parametrically varied).
I save these text files in the folder ‘model’. The stimulus is of course most important, but I also wrote some matlab scripts to create them for behavioral and eye parameters.
Convolve the EV’s with a double gamma HRF			
Use the Contrast & F-tests tab to set the EV(s) of interest

### Post-stats
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
