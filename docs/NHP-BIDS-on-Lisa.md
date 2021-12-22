The main documentation for the BIDS pipeline is at [NHP-BIDS processing](NHP-BIDS_processing.md).
More information on the LISA system can be found here: https://userinfo.surfsara.nl/systems/lisa

We have (at the time of writing) a project directory at:

    /projects/cortalg/
    
These project spaces are set to expire yearly. However, you can ask Surfsara for extensions. 
Caspar v.L. and Boy M. helped get the project space to begin with. General contact: helpdesk@surfsara.nl


Setting up your LISA account
============================
1. Apply for a LISA account at Surfsara. This requires an email to helpdesk@surfsara.nl. Ask a colleague with access for a template email so you know what information they will need to set you up (NB: link to University of Amsterdam is required) .
2. Have one of your collaborators request that you'll be given access to the project space.


Setting up the BIDS directory on LISA
=====================================

Log in to the cluster using ssh:

    ssh <username>@lisa.surfsara.nl

Clone the repo:

    git clone git@github.com:VisionandCognition/NHP-BIDS.git
    
If desired, you can create links to the shared project directory:

    cd ~/NHP-BIDS
    ls /project/cortalg/NHP-BIDS/
    ln -s /project/cortalg/NHP-BIDS/manual-masks .
    ln -s /project/cortalg/NHP-BIDS/scratch .
    ln -s /project/cortalg/NHP-BIDS/sourcedata .
    ln -s /project/cortalg/NHP-BIDS/sub-eddy .
    ln -s /project/cortalg/NHP-BIDS/sub-danny .
    ln -s /project/cortalg/NHP-BIDS/sub-<MONKEY> . # add more monkeys when necessary
    ln -s /project/cortalg/NHP-BIDS/derivatives .
    ln -s /project/cortalg/NHP-BIDS/workingdirs .
    
Derivatives also contains a folder manual-mask, which is there for historic reasons but should eventually be removed.

Moving data across your local machine and LISA
==============================================

You can mount LISA as an ssh-mapped drive using sshfs (see https://github.com/libfuse/sshfs) and easily move data or sync folders. Alternatively, you can use an ftp-client to access the drive with the ssh protocol.


Setting up python and nipype on LISA
==============================================

Download the anaconda installer script and move it your LISA drive.
    
    https://conda.io/docs/user-guide/install/download.html

Install anaconda 3 by running the installer script (you may need to change permissions)

Install nipype:

    pip install git+https://github.com/VisionandCognition/nipype.git


Mount LISA disks on your local system (for syncing and data transfer)
=====================================================================

In order to map LISA directories to a local machine (mac, linux), I use sshfs (https://github.com/libfuse/sshfs). On the local machines I have bash script to mount the home folder and our project folder as separate disks that are then accessible like any other drive ('open with fsleyes' works for instance).

For linux, the mount script (mount-lisa.sh) reads:
`!#/bin/bash
sshfs -o reconnect <username>@lisa.surfsara.nl:/home/<username> /media/LISA_home 
sshfs -o reconnect <username>@lisa.surfsara.nl:/project/<projectfolder> /media/LISA_<project>`

For mac, it's:
`!#/bin/bash
sshfs <username>@lisa.surfsara.nl:/home/<username> /Volumes/sshfs/LISA_home -o defer_permissions -o volname=LISA_home
sshfs <username>@lisa.surfsara.nl:/nfs/<projectfolder> /Volumes/sshfs/LISA_<project> -o defer_permissions -o volname=LISA_<project>`

The unmount scripts (unmount-lisa.sh) for both simply read:
`!#/bin/bash
umount <whatever_you_mounted_to_and_repeat_this_line_for_all_mounts>`

Don't forget to make these scripts executable (`chmod +x <script.sh>`). This approach furthermore assumes that you have configured a password-less login to LISA using the RSA key-pairing (instructions here: https://userinfo.surfsara.nl/systems/lisa/user-guide/connecting-and-transferring-data#sshkey)

I then use FreeFileSync (https://freefilesync.org/) to keep folders in different locations synced.
