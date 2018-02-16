For processing data using the BIDS format, see:

https://github.com/VisionandCognition/NHP-BIDS/

1. Create a `copy-to-bids.sh` script in the `Data_raw/SUBJ/YYYYMMDD` folder, and run it.
   * Base script off of existing script, for example, `Data_raw/EDDY/20180125/copy-to-bids.sh`.
   * In order to match the runs with the behavioral data, you either need to the notes that relate the run numbers with the behavioral timestamps, or you need to correspond the AcquisitionTime (in the json files, created by dcm2niix) with the behavioral timestamps. For example, the log `Behavior/Eddy_Curve_Tracing_StimSettings_CTShapedCheckerboard_Spinoza_3T_20180117T1207-T1215.49` matches with the run 8, which has an acquisition time of `12:08:54.410000`.
2. Modify `code/bids_templates.py` to add the new session (and subject, if needed).
   * May be replaced completely by csv list in the future.
3. Create or modify csv file that lists the runs to process.
4. Run `./code/bids_minimal_preprocessing.py` from your BIDS root directory (this file also has instructions in the file header).
  * example: `clear && ./code/bids_minimal_processing.py --csv curve-tracing-20180125-run02.csv  |& tee log-minproc.txt`
  * help: `./code/bids_minimal_processing.py --help`
5. Run `./code/resample_isotropic_workflow.py`
  * example: `clear && ./code/resample_isotropic_workflow.py --csv curve-tracing-20180125-run02.csv |& tee log-resample.txt`
6. Run `./code/preprocessing_workflow.py`
  * example: `clear && ./code/preprocessing_workflow.py --csv curve-tracing-20180125-run02.csv |& tee log-preproc.txt`
  * pbs: on `lisa.surfsara.nl` go to `NHP-BIDS` directory and run `qsub code/pbs/preprocess_SESSION.job`, where SESSION defines which session / run to process.
7. Run `./code/modelfit_workflow.py`
  * debug: `clear && python -m pdb ./code/modelfit_workflow.py --csv curve-tracing-20180125-run02.csv |& tee log-modelfit.txt`
  * normal: `clear && ./code/modelfit_workflow.py --csv curve-tracing-20180125-run02.csv |& tee log-modelfit.txt`
  * pbs: on `lisa.surfsara.nl` go to `NHP-BIDS` directory and run `qsub code/pbs/modelfit.job` (modify file or duplicate thereof as needed).
