The main documentation for the BIDS pipeline is at [BIDS processing](BIDS_processing.md).

We have (at the time of writing this) a project directory at:

    /nfs/cortalg/
    
I think it is currently set to expire on July 1st. However, you could ask Surfsara for extension. 
Caspar v.L. and Boy M. helped get the project space to begin with.

Setting up the BIDS directory
=============================

Clone the repo:

    git clone git@github.com:VisionandCognition/NHP-BIDS.git
    
If desired, you can create links to the shared project directory:

    cd ~/NHP-BIDS
    ls /nfs/cortalg/NHP-BIDS/
    ln -s /nfs/cortalg/NHP-BIDS/scratch .
    ln -s /nfs/cortalg/NHP-BIDS/sourcedata .
    ln -s /nfs/cortalg/NHP-BIDS/derivatives .
    
Derivatives contains manual-mask, which is actually in the repository.
Hence, it is ugly making this symbolic link. Maybe manual-mask should be moved out of derivatives.

Syncing Project dir
==================

Using FreeFileSync
------------------

This is a bit involves. I first create a mount point for the project dir on my local system (`/mnt/lisa-cortalg/`).
This will only work from SURFSARA white-listed IP addresses.
My fstab entry looks like:

    jonathan@lisa.surfsara.nl:/nfs/cortalg /mnt/lisa-cortalg fuse.sshfs noauto,x-systemd.automount,_netdev,users,idmap=user,transform_symlinks,identityfile=/home/jonathan/.ssh/id_rsa,allow_other,uid=1000,gid=1000,allow_other,reconnect 0 0

Then I set it to sync with my local BIDS-NHP directory (`/big/NHP_MRI/NHP-BIDS/`).

    <?xml version="1.0" encoding="UTF-8"?>
    <FreeFileSync XmlFormat="8" XmlType="BATCH">
        <MainConfig>
            <Comparison>
                <Variant>TimeAndSize</Variant>
                <Symlinks>Exclude</Symlinks>
                <IgnoreTimeShift/>
            </Comparison>
            <SyncConfig>
                <Variant>TwoWay</Variant>
                <DetectMovedFiles>false</DetectMovedFiles>
                <DeletionPolicy>RecycleBin</DeletionPolicy>
                <VersioningFolder Style="Replace"/>
            </SyncConfig>
            <GlobalFilter>
                <Include>
                    <Item>*</Item>
                </Include>
                <Exclude>
                    <Item>/.Trash-*/</Item>
                    <Item>/.recycle/</Item>
                </Exclude>
                <TimeSpan Type="None">0</TimeSpan>
                <SizeMin Unit="None">0</SizeMin>
                <SizeMax Unit="None">0</SizeMax>
            </GlobalFilter>
            <FolderPairs>
                <Pair>
                    <Left>/big/NHP_MRI/NHP-BIDS/</Left>
                    <Right>/mnt/lisa-cortalg/NHP-BIDS/</Right>
                    <LocalFilter>
                        <Include>
                            <Item>sourcedata</Item>
                            <Item>derivatives</Item>
                            <Item>sub-*</Item>
                            <Item>scratch</Item>
                        </Include>
                        <Exclude/>
                        <TimeSpan Type="None">0</TimeSpan>
                        <SizeMin Unit="None">0</SizeMin>
                        <SizeMax Unit="None">0</SizeMax>
                    </LocalFilter>
                </Pair>
            </FolderPairs>
            <IgnoreErrors>false</IgnoreErrors>
            <PostSyncCommand Condition="Completion"/>
        </MainConfig>
        <BatchConfig>
            <ErrorDialog>Show</ErrorDialog>
            <PostSyncAction>Exit</PostSyncAction>
            <RunMinimized>true</RunMinimized>
            <LogfileFolder Limit="1000">/tmp/logs-freefilesync</LogfileFolder>
        </BatchConfig>
    </FreeFileSync>
