import glob
import os
import sys
import subprocess


def print_run(cmd):
    print('%s\n' % cmd)
    return os.system(cmd)


def reorient_functs(session_path):
    funct_path = glob.glob('%s/run0[0-9][0-9]/funct/' % (session_path))

    bold = 'funct.nii.gz'
    ro_bold = 'foi.nii.gz'
    ro2st_bold = 'fois.nii.gz'

    for cur_run in list(funct_path):
        print('\nRe-orienting %s\n' % cur_run)
        # make symbolic link if 'funct.nii.gz' doesn't exist
        bold_path = os.path.join(cur_run, bold)
        if not os.path.isfile(bold_path):
            nii_files = glob.glob(os.path.join(cur_run, '*.nii.gz'))
            if len(nii_files) == 1:
                print_run('ln -s "%s" "%s"' % (nii_files[0], bold_path))
            else:
                print('%s file not found but there were multiple ' +
                      '(or no) nifti files.' % bold_path)

        # re-orient sphinx and reslice to 1mm isotropic voxels
        print_run("mri_convert -i %s -o %s --sphinx -vs 1 1 1" %
                  (os.path.join(cur_run, bold),
                   os.path.join(cur_run, ro_bold)))

        # re-orient to standard
        print_run("fslreorient2std %s %s" %
                  (os.path.join(cur_run, ro_bold), 
                   os.path.join(cur_run, ro2st_bold)))
