#!/usr/bin/env python3

import glob
import os
import sys
import errno

import process_nhp_mri as nhp


def mkdir_p(path):
    """ http://stackoverflow.com/questions/600268/
            mkdir-p-functionality-in-python
    """
    try:
        os.makedirs(path)
    except OSError as exc:  # Python >2.5
        if exc.errno == errno.EEXIST and os.path.isdir(path):
            pass
        else:
            raise


def preprocess_all(session_path):
    mkdir_p("%s/QA" % session_path)
    nhp.reorient_functs(session_path)

    # you can also run "get_motion_outliers"
    nhp.get_motion_outliers(session_path)


if __name__ == '__main__':
    session_path = None
    if len(sys.argv) == 1:
        if not len(glob.glob('run???')):
            print("No 'run0xx' directory found in current location.")
        else:
            session_path = os.getcwd()
    elif len(sys.argv) == 2:
        session_path = sys.argv[1]

    if session_path is not None:
        sys.exit(preprocess_all(session_path))
    else:
        print("Syntax:")
        print("\t%s [session_path]")
        print("\nWhere session_path is a directory that contains "
              "run0xx directories.")
        print("session_path is optional if the current directory "
              "contains run0xx directories")
