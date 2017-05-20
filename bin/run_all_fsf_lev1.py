#!/usr/bin/python

# This script will run each subjects design.fsf

import os
import glob
import sys


def print_run(cmd):
    print('%s\n' % cmd)
    return os.system(cmd)

def run_all_fsf_lev1(session_path):
    fsfdir="%s/scripts/fsf_lev1" % (session_path)

    fsffiles=glob.glob("%s/lev1/design_run[0-9][0-9][0-9].fsf" % (fsfdir))

    for fsffile in fsffiles:
        print_run("feat %s"%(fsffile))


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
        sys.exit(run_all_fsf_lev1(session_path))
    else:
        print("Syntax:")
        print("\t%s [session_path]")
        print("\nWhere session_path is a directory that contains run0xx directories.")
        print("session_path is optional if the current directory contains run0xx directories")
