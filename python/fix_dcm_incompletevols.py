import os, sys, shutil, glob
import pydicom, numpy

dcmpath = sys.argv[1] 

# get all dcm files
dcm_list = (glob.glob(dcmpath + '/*.dcm'))

# get the temporal position tag for all dcm files
print('Scanning ' + dcmpath + ' for dcm files...')
volnum =[];
for f in dcm_list:
    dcm_info = pydicom.filereader.dcmread(f,stop_before_pixels=True)
    volnum.append(dcm_info.TemporalPositionIdentifier)

# how many slices in each volume
vol_list=[];
for i in numpy.unique(volnum):
    vol_list.append(volnum.count(i))

# what is the temporal label of the last volume
lastvol=numpy.max(volnum)

# get the indexes of the slices belonging to the last (incomplete) volume
if vol_list[-1] != vol_list[0]:
    del_dcm = [i for i,x in enumerate(volnum) if x==numpy.max(volnum)]
    print('The following slice files will be ignored')
    print(del_dcm)
    
    if os.path.isdir(dcmpath + '/orphan_dcm') is False:
        os.mkdir(dcmpath + '/orphan_dcm')
        os.mkdir(dcmpath + '/corrected_dcm')

    print('Moving ' + str(len(del_dcm)) + ' orphan dcm files to orphan_dcm')
    # print('Moving the following orphan dcm files to orphan_dcm')
    for f in del_dcm:
        #print(dcm_list[f])
        shutil.move(dcm_list[f],dcmpath + '/orphan_dcm/' + dcm_list[f].split('/')[-1])
    
    print('Moving the rest of the dcm files to corrected_dcm')
    for f in glob.glob(dcmpath + '/*.dcm'):
        shutil.move(f,dcmpath + '/corrected_dcm/')
    
