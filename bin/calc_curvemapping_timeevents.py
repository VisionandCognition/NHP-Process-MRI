#!/usr/bin/env python
import os
import sys
import glob
import re
import pandas as pd
import itertools

import pdb
import errno


def mkdir_p(path):
    try:
        os.makedirs(path)
    except OSError as exc:  # Python >2.5
        if exc.errno == errno.EEXIST and os.path.isdir(path):
            pass
        else:
            raise


class Event(object):
    def __init__(self, start_s, stop_s=None, event_num=1, dur_s=None):
        self.time_s = start_s
        if dur_s is not None:
            self.dur_s = float(dur_s)
        elif stop_s is not None:
            self.dur_s = stop_s - start_s
        else:
            self.dur_s = 0

        self.event_num = event_num


def process_events(events, stimparams):

    split_ev = {
        'BlankL': [],  # When correct response
        'BlankR': [],  # When correct response
#        'CurveSegL': [],  # When correct response
#        'CurveSegR': [],
        'CurveSegUL': [],
        'CurveSegDL': [],
        'CurveSegUR': [],
        'CurveSegDR': [],
        'GapL': [],  # When correct response
        'GapR': [],
        'GapUL': [],
        'GapDL': [],
        'GapUR': [],
        'GapDR': [],
        'CircleDiamondUL': [],  # When correct response
        'CircleDiamondDL': [],
        'CircleDiamondUR': [],
        'CircleDiamondDR': [],
        'CircleSquareUL': [],
        'CircleSquareDL': [],
        'CircleSquareUR': [],
        'CircleSquareDR': [],
        'CurveIncorrect': [],  # False hit / wrong hand
        'CurveNoResponse': [],
        'CurveFixationBreak': [],
        'CurveNotCorrect': [],  # Catch-all: Incorrect, NoResponse, Fix. Break
        'HandLeft': [],
        'HandRight': [],
        'Reward': [],
    }

    cur_stim = None

    curve_stim_on = None
    curve_response = None
    curve_switched = False

    fixation_stim_on = None
    began_fixation = None
    curr_state = None
    has_ManualRewardField = False

    mri_triggers = events[(events['event'] == 'MRI_Trigger') &
                          (events['info'] == 'Received')]
    start_time_s = mri_triggers.iloc[0].time_s
    events['time_s'] = events['time_s'] - start_time_s
    events['record_time_s'] = events['record_time_s'] - start_time_s

    for irow, event in events.iterrows():
        if event.event == 'NewState':
            curr_state = event.info
            if curr_state == 'SWITCHED':
                curve_switched = True

        if event.event == 'NewStimulus':
            tsk = event.task.replace(' ', '')
            if tsk in stimparams.keys():
                cur_stim = [
                    stimparams[tsk].iloc[int(event.info)]['LeftStim'],
                    stimparams[tsk].iloc[int(event.info)]['RightStim']]

                if cur_stim[0] == 'None':
                    cur_stim[0] = 'BlankL'
                if cur_stim[1] == 'None':
                    cur_stim[1] = 'BlankR'
                if cur_stim[1] == 'CurveSegR':  # CurveSegX doesn't appear
                    cur_stim[1] = 'BlankR'

        elif event.event == 'StimulusKey:CombinedStim':
            cur_stim = event.info.split('+')

            if cur_stim[0] == 'None':
                cur_stim[0] = 'BlankL'
            if cur_stim[1] == 'None':
                cur_stim[1] = 'BlankR'
            if cur_stim[1] == 'CurveSegR':  # CurveSegX doesn't appear
                cur_stim[1] = 'BlankR'

        elif event.event == 'NewState' and event.info == 'TRIAL_END':
            cur_stim = None
            curve_stim_on = None
            curve_response = None
            curve_switched = False
            fixation_stim_on = None

        elif event.event == 'NewState' and event.info == 'PRESWITCH':
            curve_stim_on = event.time_s

        elif (event.task == 'Fixation' and event.event == 'NewState' and
              event.info == 'FIXATION_PERIOD'):
            fixation_stim_on = event.time_s

        elif event.event == 'NewState' and event.info == 'POSTSWITCH':

            assert (event.task == 'Curve Mapping' or
                    event.task == 'No Stim Hand Response')
            assert curve_stim_on is not None

            event_type = cur_stim

            if curve_response == 'INCORRECT':
                event_type = ['CurveIncorrect']

            elif curve_response is None:
                if curve_switched:
                    event_type = ['CurveNoResponse']
                else:
                    event_type = ['CurveFixationBreak']

            elif curve_response == 'FixationBreak':
                event_type = ['CurveFixationBreak']

            else:
                assert curve_response == 'CORRECT', (
                    'Unhandled curve_response %s' % curve_response)

            for evtype in event_type:
                split_ev[evtype].append(Event(curve_stim_on, event.time_s))

                # CurveNotCorrect event is a renaming / generalization of the
                #   wrong response types
                if (evtype == 'CurveIncorrect' or
                        evtype == 'CurveNoResponse' or
                        evtype == 'CurveFixationBreak'):
                    split_ev['CurveNotCorrect'].append(Event(curve_stim_on,
                                                             event.time_s))

        elif event.event == 'ResponseGiven' and curve_response is None:
            curve_response = event.info

        # It seems that the following may create more fixation breaks than
        #    what is reasonable.
        # elif (event.event == 'Fixation' and event.info == 'Out' and
        #       curve_response is None):
        #     curve_response = 'FixationBreak'

        elif event.event == 'Response_Initiate':
            split_ev['Hand%s' % event.info].append(Event(event.time_s))

        elif event.event == 'ResponseReward' or event.event == 'TaskReward':
            reward_dur = event.info
            split_ev['Reward'].append(Event(event.time_s, dur_s=reward_dur))

        elif event.event == 'ManualReward':
            reward_dur = event.info
            has_ManualRewardField = True
            split_ev['Reward'].append(Event(event.time_s, dur_s=reward_dur))

        elif event.event == 'Reward' and event.info == 'Manual':
            split_ev['Reward'].append(Event(event.time_s, dur_s=0.04))
            assert not has_ManualRewardField, (
                "Event log should not have ('Reward','Manual') "
                "entry if it has ('ManualReward') entry.")

    return split_ev


def main(session_path, beh_paths=None):
    if beh_paths is None:
        beh_paths = glob.glob('%s/run0[0-9][0-9]/behavior' % (session_path))
        beh_paths.sort()

    for cur_beh in beh_paths:
        run_path = os.path.dirname(os.path.abspath(cur_beh))
        run = os.path.split(run_path)[1]
        assert len(run), "Could not process behavior directory %s" % cur_beh

        beh_dir = os.path.join(session_path, run, 'behavior')
        if not os.path.isdir(cur_beh):
            print('Path not found for %s: %s' % (run, cur_beh))
            continue

        print('\nProcessing behavior of %s.' % run)

        split_events = None
        task_dirs = glob.glob('%s/*/' % (beh_dir))
        assert len(task_dirs), 'The behavior directory %s should have at' \
            ' least one subdirectory'

        for task_group_path in glob.iglob('%s/*/' % (beh_dir)):
            print(task_group_path)

            # Read stimulus parameter files
            stim_params = dict()
            for stim_csv in glob.iglob('%s/*.stimulus-params.csv' %
                                       task_group_path):
                m = re.match(r'.*_([^_]*)\.stimulus-params\.csv',
                             os.path.split(stim_csv)[1])

                assert m  # if matches glob.iglob, should match with re.match

                task = m.group(1).replace('_', '')
                stim_params[task] = pd.read_csv(stim_csv)

            # Find the overall/event log file
            eventlog_pat = re.compile(r'Log_.*_\d+T\d+(?:_eventlog)?\.csv')
            csv_logs = [os.path.split(f)[1] for f in glob.glob(
                '%s/Log_*.csv' % task_group_path)]
            matches = [re.match(eventlog_pat, log) is
                       not None for log in csv_logs]

            event_log = [log for log, match in
                         itertools.izip(csv_logs, matches) if match]
            assert len(event_log) != 0, (
                "There were no matching event logs in %s" % task_group_path)
            assert len(event_log) <= 1, (
                "There must only be one event log in %s." % task_group_path)

            events = pd.read_csv(os.path.join(
                task_group_path,
                event_log[0]))

            assert split_events is None, (
                'Events need to be merged before '
                'multiple task groups are handled.')

            split_events = process_events(events, stim_params)

            mkdir_p(os.path.join(run_path, 'model'))

            for task, task_events in split_events.items():
                # open file in model directory
                model_path = os.path.join(run_path, 'model', '%s.txt' % task)

                with open(model_path, 'w') as f:
                    for ev in task_events:
                        f.write('%03f\t%f\t%d\n' %
                                (ev.time_s, ev.dur_s, ev.event_num))

            # for log_csv in glob.iglob('%s/Log_*.csv' % task_group_path):
            #     m = re.match(r'Log_.*_\d+T\d+_([^_]*)\.csv',
            #                  os.path.split(log_csv)[1])

            #     if not m:
            #         print('The filename %s was not in expected format,'
            #               ' skipping.' %
            #               os.path.split(log_csv)[1])
            #         continue

            #     task = m.group(1).replace('_', '')

            #     log = pd.read_csv(log_csv)

            #     if task in stim_params.keys():
            #         process(log, stim_params[task])
            #     import pdb
            #     pdb.set_trace()


if __name__ == '__main__':
    session_path = None
    beh_paths = None
    if len(sys.argv) <= 2 and len(glob.glob('run???')):
        session_path = os.getcwd()
    else:
        print "No 'run0xx' directory found in current location."

    if len(sys.argv) == 2:
        if session_path is None:
            session_path = sys.argv[1]
        else:
            beh_paths = [sys.argv[1]]
    elif len(sys.argv) == 3:
        session_path = sys.argv[1]
        beh_paths = [sys.argv[2]]

    if session_path is not None:
        sys.exit(main(session_path, beh_paths))
    else:
        print("Syntax:")
        print("\t%s [session_path] [behavior_paths]")
        print("\nWhere session_path is a directory that contains"
              " run0xx directories.")
        print("session_path is optional if the current directory "
              "contains run0xx directories")
        print("behavior_paths by default is all the run0xx directories.")
