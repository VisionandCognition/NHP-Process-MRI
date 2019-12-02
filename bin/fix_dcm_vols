#!/usr/bin/env python

# Call this script with the path to your dicom folder as argument
# e.g., python fix_dcm_incompletevols.py dicom_folder
# p.c.klink@gmail.com

import os, sys, shutil, glob
import pydicom, numpy

if len(sys.argv) > 1:
    dcmpath = sys.argv[1] 

    # get all dcm files
    dcm_list = (glob.glob(dcmpath + '/*.dcm'))

    # get the temporal position tag for all dcm files
    print('Scanning ' + dcmpath + ' for dcm files...')
    vol_num =[];
    for f in dcm_list:
        dcm_info = pydicom.filereader.dcmread(f,stop_before_pixels=True)
        vol_num.append(dcm_info.TemporalPositionIdentifier)

    # how many slices in each volume
    vol_list=[];
    for i in numpy.unique(vol_num):
        vol_list.append(vol_num.count(i))
    
    print('Number of slices in each volume')
    print(vol_list)

    # get the indexes of the slices belonging to the last (incomplete) volume
    if vol_list[-1] != vol_list[0]:
        del_dcm = [i for i,x in enumerate(vol_num) if x==numpy.max(vol_num)]
        print('The following slice files will be taken out')
        print(del_dcm)
        
        if os.path.isdir(dcmpath + '/orphan_dcm') is False:
            os.mkdir(dcmpath + '/orphan_dcm')
            os.mkdir(dcmpath + '/corrected_dcm')

        print('Moving ' + str(len(del_dcm)) + ' orphan dcm files to orphan_dcm')
        for f in del_dcm:
            shutil.move(dcm_list[f],dcmpath + '/orphan_dcm/' + dcm_list[f].split('/')[-1])
        
        print('Moving the rest of the dcm files to corrected_dcm')
        for f in glob.glob(dcmpath + '/*.dcm'):
            shutil.move(f,dcmpath + '/corrected_dcm/')
    else: 
        print('All volumes are complete, will not mess with dcm files.')
else:
    print('No dicom-folder specified. Please re-run with path argument.')    
