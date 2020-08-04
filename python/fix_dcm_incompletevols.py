# Call this script with the path to your dicom folder as argument
# e.g., python fix_dcm_incompletevols.py dicom_folder
# p.c.klink@gmail.com
#
# Changes
# July 2020 - Generalizations and modifications to the comparison logic added by B. Sutton
# Cropping the series after identifying the minimum number of full acquisitions by reading the dicom header and limiting on AcquisitionNumber prevents sorting issues, which may lead to dropping slices mid-series... messing up the conversion to nifti

import os, sys, shutil, glob
import pydicom

if len(sys.argv) > 1:
    dcm_dir = sys.argv[1]
    dcmpath = os.path.join(os.getcwd(), dcm_dir)

    valid_dcm_extns = ['dcm','ima','dicom'] # can add other dicom extensions as necessary
    possible_files = glob.glob(os.path.join(dcmpath, '*'))
    print('Found {} items in {}'.format(len(possible_files),os.path.join(dcmpath, '*')))

    # check each possible entry to make sure the file is a dicom file
    dcm_list = [f for f in possible_files if f.split('.')[-1].lower() in valid_dcm_extns]
    dcm_list.sort()
    if not dcm_list:
        print('Did not find dicom files to convert.\n')
    else:
        # get the temporal position tag for all dcm files
        # Logic for the next block is to find repeating field that prescribes acquisition. The repeating field will be counted below to define the number of slices.
        print('Scanning ' + dcmpath + ' for dcm files...')
        volnum =[];
        for f in dcm_list:
            try:
                dcm_info = pydicom.filereader.dcmread(f,stop_before_pixels=True)
                #volnum.append(dcm_info.TemporalPositionIdentifier) # may work on some systems
                volnum.append(dcm_info.SliceLocation)
            except Exception as e:
                print('{}: {}'.format(f,e))

        # how many slices in each volume; identify the fewest number of repeats
        vol_list=[]
        for i in set(volnum):
            vol_list.append(volnum.count(i))

        if max(vol_list) != min(vol_list): # Test for a full collection
            last_full_acq = min(vol_list)*len(vol_list) # Determine the total number of files after cropping
            print('Using {} files ({} slices*{} complete volumes)'.format(last_full_acq, len(vol_list), min(vol_list)))

            corr_dcm_list = []
            orphaned_list = []

            # Find the number of acquisitions for each slice that correspond to the minimum number of full volumes acquired.
            for dcm_file in dcm_list:
                try:
                    dcm_info = pydicom.filereader.dcmread(dcm_file,stop_before_pixels=True)
                    if not dcm_info.SliceLocation:
                        print('{} part of scout?'.format(dcm_file))
                        orphaned_list.append(dcm_file)
                    elif dcm_info.AcquisitionNumber > min(vol_list):
                        orphaned_list.append(dcm_file)
                    else:
                        corr_dcm_list.append(dcm_file)
                except Exception as e:
                    print('{}: {}'.format(f,e))

            # Create directory structures
            if os.path.isdir(os.path.join(dcmpath , 'orphan_dcm')) is False:
                os.mkdir(os.path.join(dcmpath , 'orphan_dcm'))
            if os.path.isdir(os.path.join(dcmpath , 'corrected_dcm')) is False:
                os.mkdir(os.path.join(dcmpath , 'corrected_dcm'))

            print('Moving {} orphan dcm files to orphan_dcm'.format(len(orphaned_list)))
            for orphan in orphaned_list:
                orphan_filename = os.path.split(orphan)
                shutil.move(orphan,os.path.join(dcmpath , 'orphan_dcm' , orphan_filename[1]))


            print('Moving the rest of the dcm files to corrected_dcm')
            for f in corr_dcm_list:
                corr_filename = os.path.split(f)
                shutil.move(f,os.path.join(dcmpath , 'corrected_dcm', corr_filename[1]))
        else:
            print('All volumes are complete, will not mess with dcm files.')
else:
    print('No dicom-folder specified. Please re-run with path argument.')
