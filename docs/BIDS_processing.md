For processing data using the BIDS format, see:

https://github.com/VisionandCognition/NHP-BIDS/

1. Create a `copy-to-bids.sh` script in the `Data_raw/SUBJ/YYYYMMDD` folder, and run it.
   * Base script off of existing script, for example, `Data_raw/EDDY/20180125/copy-to-bids.sh`.
2. Modify `code/bids_templates.py` to add the new session (and subject, if needed).
   * May be replace completely by csv list in the future.
3. Create or modify csv file that lists the runs to process.
4. Run `./code/bids_minimal_preprocessing.py` from your BIDS root directory (this file also has instructions in the file header).
  * example: `clear && ./code/bids_minimal_processing.py --csv curve-tracing-20180125-run02.csv  |& tee log.txt`
5. Run `./code/resample_isotropic_workflow.py`
6. Run code/preprocessing_workflow.py
7. Run code/modelfit_workflow.py

