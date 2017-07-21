import os
import glob
import sys
from pathlib import Path
import re
from process_nhp_mri import make_fsf_designs
import argparse


def setup_fsf_lev1(fsf_ex_script, session_path, auto_fsf_dir=False):
    """
        If auto_fsf_dir is true, the output_dir variable is used to
        get the name of this FSL design. For example, if the output dir
        is /NHP/path/design1, then the design name will be design1.
    """
    script_dir = os.path.join(session_path, 'scripts')

    with open(fsf_ex_script, 'r') as fi:
        # Get scan data from file name of session_path, last occurrence
        for date_match in re.finditer(
                r'/(20\d\d\d\d\d\d)(?:/|$)', session_path):
            pass
        scan_date = date_match.group(1)

        contents = fi.read()
        contents = re.sub(r'^set fmri\(npts\) \d+$',
                          r'set fmri(npts) NTPTS', contents,
                          flags=re.MULTILINE)
        contents = re.sub(r'\brun\d\d\d\b', r'runRUNNUM', contents)
        # allow the example fsl script to be from another directory
        contents = re.sub(r'\b20\d\d\d\d\d\d\b', scan_date, contents)
        if auto_fsf_dir:
            output_dirm = re.search(r'^set fmri\(outputdir\) [\'"](.*)[\'"]$',
                                    contents, flags=re.MULTILINE)
            design_name = os.path.basename(output_dirm.group(1))
        else:
            design_name = None

    if auto_fsf_dir:
        fsf_dir = '-'.join(['fsf_lev1', design_name])
    else:
        fsf_dir = 'fsf_lev1'

    scripts_fsf_dir = os.path.join(script_dir, fsf_dir)
    os.makedirs(scripts_fsf_dir, exist_ok=True)

    fsf_template_path = Path(
        os.path.join(scripts_fsf_dir, 'design_template.fsf'))

    if fsf_template_path.exists():
        print('Error: %s already exists, cowardly refusing to overwrite.' %
              fsf_template_path)
        return

    with fsf_template_path.open('w') as fo:
        fo.write(contents)

    print('Template written success!\n')

    os.makedirs(os.path.join(scripts_fsf_dir, 'lev1'), exist_ok=True)
    make_fsf_designs(session_path, fsf_dir)
    print('Individual run scripts created (I\'m guessing)!\n')
    print('To continue, run the following:')
    print('\tpmri_run_all_fsf_lev1 -p %s --fsf-dir %s' % (
        session_path, fsf_dir))
