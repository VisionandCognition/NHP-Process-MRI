#!/usr/bin/python2.7

import glob
import os
import sys

path = '/NHP_MRI/Data_proc'
sub = 'EDDY'
sess = '20160804'

script_path = '%s/%s/%s/scripts/'%(path,sub,sess)
script_subpath = '%s/subscripts/'%(script_path)

# re-orient the functional
os.system("%s/reorient_functs.py"%(script_subpath))

# get motion outliers
os.system("%s/get_motion_outliers.py"%(script_subpath))

import process_nhp_mri as nhp

def preprocess_all(session_path):
    nhp.reorient_functs(session_path)
    nhp.get_motion_outliers(session_path)

if __name__ == '__main__':
    session_path = None
    if len(sys.argv) == 1:
        if not len(glob.glob('run???')):
            print "No 'run0xx' directory found in current location."
        else:
            session_path = os.getcwd()
    elif len(sys.argv) == 2:
        session_path = sys.argv[1]

    if session_path is not None:
        sys.exit(preprocess_all(session_path))
    else:
        print("Syntax:")
        print("\t%s [session_path]")
        print("\nWhere session_path is a directory that contains run0xx directories.")
        print("session_path is optional if the current directory contains run0xx directories")
