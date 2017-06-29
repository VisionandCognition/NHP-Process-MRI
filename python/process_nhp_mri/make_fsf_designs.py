#!/usr/bin/env python3

import os
import glob


def make_fsf_designs(session_path):
    fsfdir = "%s/scripts/fsf_lev1" % (session_path)
    fsf_templ = 'design_template.fsf'
    fsf_folder = 'lev1'

    # Get all the paths
    subdirs = glob.glob("%s/run0[0-9][0-9]/funct" % (session_path))

    for dir in list(subdirs):
        splitdir = dir.split('/')
        splitdir_run = splitdir[-2]
        runnum = splitdir_run[-3:]
        print(runnum)

        try:
            ntime = os.popen('fslnvols %s/fois_roi.nii.gz' %
                             (dir)).read().rstrip()
        except:
            ntime = os.popen('fslnvols %s/fois.nii.gz' % (dir)).read().rstrip()

        replacements = {'NTPTS': ntime, 'RUNNUM': runnum}
        with open("%s/%s" % (fsfdir, fsf_templ)) as infile:
            with open("%s/%s/design_run%s.fsf" %
                      (fsfdir, fsf_folder, runnum), 'w') as outfile:
                contents = infile.read()
                for src, target in replacements.items():
                    contents = contents.replace(src, target)
                outfile.write(contents)
