Processing event logs without enough stimulus info
-------------------

For data collected with the Curve tracing code (which includes the localizer task, CTShapedCheckerboard), there should be an "event" (a row in the event log) that gives the necessary (human-readable) information about the stimulus. For CTShapedCheckerboard, it is "CombinedStim". Some of the log files don't have this information included. However, there should always be an event "NewStimulus" that contains the stimulus index from the stimulus file. For example, CTShapedCheckerboard has the following event:


| time_s	 |task                      | event       |info |	record_time_s  |
| -------- |:------------------------:| -----------:|----:|---------------:|
| 143.5002 |CT-Shaped Checkerboard RH | NewStimulus	|6	  | 143.5477       |

This means that the stimulus corresponds to row 6 of the stimulus file. The task gives a hint for the stimulus file. For example, CT-Shaped Checkerboard RH correspond to:

https://github.com/VisionandCognition/VCscripts-MRI/blob/master/TRACKER_PTB/Curve_Tracing/Experiment/StimSettings/CheckerboardCurveStimulus_RightHemisphere.csv

I have modified the script [bids_convert_csv_eventlog](https://github.com/VisionandCognition/NHP-BIDS/blob/master/code/bids_convert_csv_eventlog) to lookup the correct `CombinedStim` values for CTCheckerboard *if* the correct stimulus files are put in the `sourcedata` func event folder and has the name specified by the task column with ".csv" added. For example, the directory:

* /NHP_MRI/NHP-BIDS/sourcedata/sub-eddy/ses-20180117/func/sub-eddy_ses-20180117_task-ctcheckerboard_run-12_events/

contains:

* CT-Shaped Checkerboard LH.csv
* CT-Shaped Checkerboard RH.csv

The script [bids_convert_csv_eventlog](https://github.com/VisionandCognition/NHP-BIDS/blob/master/code/bids_convert_csv_eventlog) is called by the bids_minimal_processing.py script. This script should be the first script called after copying the data from Data_raw to NHP-BIDS. See [BIDS processing docs](BIDS_processing.md).
