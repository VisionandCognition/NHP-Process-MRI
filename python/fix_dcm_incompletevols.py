# Call this script with the path to your dicom folder as argument
# e.g., python fix_dcm_incompletevols.py dicom_folder
# p.c.klink@gmail.com
# Generalizations and modifications to the comparison logic added by neurosutton

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
                #volnum.append(dcm_info.TemporalPositionIdentifier)
                volnum.append(dcm_info.SliceLocation)
            except Exception as e:
                print('{}: {}'.format(f,e))

        # how many slices in each volume
        vol_list=[]
        # setup a dictionary to handle all the slice locations and number of acquisitions at that location
        vol_dict = {}
        for i in set(volnum):
            vol_dict[volnum] = volnum.count(i)
            vol_list.append(volnum.count(i))

        # get the indexes of the slices belonging to the last (incomplete) volume
        if max(vol_list) != min(vol_list): # First index vs last may not work, depending on acquisition scheme (i.e., even-first, interleaved)
            last_full_acq = min(vol_list)*len(vol_list)
            print('Using {} files ({} slices*{} complete volumes)'.format(last_full_acq, len(vol_list), min(vol_list)))

            # Reset the max counter for each of the slice locations to the minimum number of complete acquisitions.
            for k in vol_dict.keys():
                vol_dict[k] = min(vol_list)
            corr_dcm_list = []
            orphaned_list = []

            # Find the number of acquisitions for each slice that correspond to the minimum number of full volumes acquired.
            for v, dcm_file in enumerate(vol):
                try:
                    dcm_info = pydicom.filereader.dcmread(dcm_file,stop_before_pixels=True)
                    vol_dict[dcm_info.SliceLocation] = vol_dict[dcm_info.SliceLocation] - 1
                    if vol_dict[dcm_info.SliceLocation] >= 0:
                        corr_dcm_list.append(dcm_file)
                    else:
                        print('Delete:{}'.format(dcm_info.SliceLocation))
                        orphaned_list.append(dcm_file)
                except Exception as e:
                    print('{}: {}'.format(f,e))

            print('The following slice files will be ignored')
            print(orphaned_list)

            if os.path.isdir(os.path.join(dcmpath , 'orphan_dcm')) is False:
                os.mkdir(os.path.join(dcmpath , 'orphan_dcm'))
            if os.path.isdir(os.path.join(dcmpath , 'corrected_dcm')) is False:
                os.mkdir(os.path.join(dcmpath , 'corrected_dcm'))

            print('Moving {} orphan dcm files to orphan_dcm'.format(len(orphaned_list)))
            # print('Moving the following orphan dcm files to orphan_dcm')
            for f in orphaned_list:
                #print(dcm_list[f])
                orphan_filename = os.path.split(orphaned_list[f])
                shutil.move(orphaned_list[f],os.path.join(dcmpath , 'orphan_dcm' , orphan_filename[1]))


            print('Moving the rest of the dcm files to corrected_dcm')
            for f in corr_dcm_list:
                shutil.move(f,os.path.join(dcmpath , 'corrected_dcm',))
        else:
            print('All volumes are complete, will not mess with dcm files.')
else:
    print('No dicom-folder specified. Please re-run with path argument.')
