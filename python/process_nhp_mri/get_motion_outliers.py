#!/usr/bin/python

import glob
import os
import sys
import subprocess


def print_run(cmd):
    print('%s\n' % cmd)
    return os.system(cmd)


def get_motion_outliers(session_path):
    bold_files = glob.glob('%s/run0[0-9][0-9]/funct/fois.nii.gz' %
                           session_path)

    # put all QA info together.
    outhtml = '%s/QA/motion_outliers.html' % session_path
    out_bad_bold_list = '%s/runs_vol_scrub.txt' % session_path

    if os.path.isfile("%s" % (out_bad_bold_list)):
        os.system("rm %s" % (out_bad_bold_list))
    if os.path.isfile("%s" % (outhtml)):
        os.system("rm %s" % (outhtml))

    for cur_bold in list(bold_files):
        print("Detecting motion outliers in %s.\n" % cur_bold)
        # Store directory name
        cur_dir = os.path.dirname(cur_bold)

        # strip off .nii.gz from file name (makes code below easier)
        cur_bold_no_nii = cur_bold[:-7]

        # Assessing motion.  This is what takes the longest
        # I got TH from here: http://www.ncbi.nlm.nih.gov/pubmed/23861343
        # Also, consider using FSL's FIX to clean your data
        if not os.path.isdir("%s/motion_assess/" % (cur_dir)):
            os.system("mkdir %s/motion_assess" % (cur_dir))

        # using an intensity based metric here.
        # Could also go with franewise displacement (--fd)
        print_run(
            ("fsl_motion_outliers -i %s -o %s/motion_assess/confound.txt " +
             "--dvars -p %s/motion_assess/dvars_plot -v > " +
             "%s/motion_assess/outlier_output.txt") % (cur_bold_no_nii, cur_dir, cur_dir, cur_dir))

        # Put confound info into html file for review later on
        os.system("cat %s/motion_assess/outlier_output.txt >> %s" % (cur_dir, outhtml))
        os.system("echo '<p>=============<p>DVARS plot %s <br><IMG BORDER=0 SRC=%s/motion_assess/dvars_plot.png WIDTH=100%s></BODY></HTML>' >> %s" % (cur_dir, cur_dir,'%', outhtml))

        # Last, if we're planning on modeling out scrubbed volumes later
        #   it is helpful to create an empty file if confound.txt isn't
        #   generated (i.e. no scrubbing needed).  It is basically a
        #   place holder to make future scripting easier
        if not os.path.isfile("%s/motion_assess/confound.txt" % (cur_dir)):
            os.system("touch %s/motion_assess/confound.txt" % (cur_dir))

        # Very last, create a list of subjects who exceed a threshold for
        #  number of scrubbed volumes.  This should be taken seriously.  If
        #  most of your scrubbed data are occurring during task, that's
        #  important to consider (e.g. subject with 20 volumes scrubbed
        #  during task is much worse off than subject with 20 volumes
        #  scrubbed during baseline.
        # These data have about 182 volumes and I'd hope to keep 140
        #  DO NOT USE 140 JUST BECAUSE I AM.  LOOK AT YOUR DATA AND
        #  COME TO AN AGREED VALUE WITH OTHER RESEARCHERS IN YOUR GROUP
        output = subprocess.check_output("grep -o 1 %s/motion_assess/confound.txt | wc -l" % (cur_dir), shell=True)
        num_scrub = [int(s) for s in output.split() if s.isdigit()]
        if num_scrub[0]>80:
            with open(out_bad_bold_list, "a") as myfile:
                myfile.write("%s\n" % (cur_bold))
