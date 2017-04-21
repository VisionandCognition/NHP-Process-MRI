#!/usr/bin/env python3

import os
import sys
import subprocess
import pdb

def system(cmd):
    result = subprocess.check_output(cmd, shell=True)
    return result.decode('utf-8').splitlines()

def process_xnat_dicoms(xnat_dir, nii_output='NII'):
    cmd = 'find "%s" -name DICOM' % xnat_dir
    dicom_dirs = system(cmd)
    os.makedirs(nii_output, exist_ok=True)
    for ddir in dicom_dirs:
        print('Processing %s' % ddir)
        system('dcm2nii -g n -o %s %s/' % (nii_output, ddir))

    system('gzip %s/*.nii')

if __name__ == '__main__':
    if len(sys.argv) == 1 and os.path.exists('xnat'):
        process_xnat_dicoms('xnat')
    if len(sys.argv) == 2:
        process_xnat_dicoms(sys.argv[1])
    elif len(sys.argv) == 3:
        process_xnat_dicoms(sys.argv[1], sys.argv[2])
    else:
        print('Syntax:')
        print('\t%s XNAT_DIR NII_OUTPUT' % os.path.basename(sys.argv[0]))
