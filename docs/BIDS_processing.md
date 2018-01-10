For processing data using the BIDS format, see:

https://github.com/VisionandCognition/NHP-BIDS/

1. Create a `copy-to-bids.sh` script in the Data_raw folder, and run it.
2. Run `./code/bids_minimal_preprocessing.py` from your BIDS root directory (this file also has instructions in the file header).
3. Run `./code/resample_isotropic_workflow.py`
4. Create or modify csv file that lists the runs to process.
5. Run code/preprocessing_workflow.py
6. Run code/modelfit_workflow.py

