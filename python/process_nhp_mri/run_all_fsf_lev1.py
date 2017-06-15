#!/usr/bin/env python3

import os
import glob


def print_run(cmd):
    print('%s\n' % cmd)
    return os.system(cmd)


def run_feat(fsf_file):
    print_run("feat %s" % fsf_file)


def run_all_fsf_lev1(session_path, njobs=None):
    if njobs is None:
        njobs_envvar = 'FSL_LEV1_NJOBS' 
        if njobs_envvar in os.environ.keys():
            njobs = int(os.environ[njobs_envvar])
        else:
            njobs = 2
            print("Running %d jobs at once. Set %s environment"
                  " variable to overwrite." % (njobs, njobs_envvar))

    fsfdir = "%s/scripts/fsf_lev1" % (session_path)

    fsffiles = glob.glob("%s/lev1/design_run[0-9][0-9][0-9].fsf" % (fsfdir))

    if njobs > 1:
        from joblib import Parallel, delayed

        Parallel(n_jobs=njobs)(delayed(run_feat)(fsffile)
                               for fsffile in fsffiles)
    else:
        for fsffile in fsffiles:
            run_feat(fsffile)
