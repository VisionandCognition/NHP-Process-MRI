This repository includes the `process_nhp_mri` Python package. To be able
to use, you should include the python directory in your PYTHONPATH:

    export PYTHONPATH=$PYTHONPATH:/PATH/TO/Process-NHP-MRI/python

This is necessary for some of the scripts in the NHP_MRI Data_proc directory.

Some of the python scripts that should not be included are in the
`Process-NHP-MRI/bin` directory. You should add this to your $PATH:

    export PATH=$PATH:/PATH/TO/Process-NHP-MRI/bin
    
The main documents can be found at [docs/NHP_fMRI_Pipeline.md](docs/NHP_fMRI_Pipeline.md)
