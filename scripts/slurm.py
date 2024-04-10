#!/usr/bin/env python3
# Author(s) : Caleb Bean, Benjamin Hicks
# slurm.py
# Purpose: Python code used to generate slurm job scripts and execute them

import subprocess
import os

job_count = 2 # Modify as additional parameter entries are placed in 'sbatch_cmds'

job_directory = '../LULESH/'
job_file_name = 'job-hw.sh'
job_path = job_directory+job_file_name

email = 'caleb.bean@ufl.edu'
# Note that currently outfiles do not get produced and the output is only available via stdout
outfile_prefix = 'lulesh_out'
errfile_prefix = 'lulesh_err'
slurmrun_cmd = 'srun ./lulesh2.0 -s '

sbatch_cmds_dict = {
    '#!/bin/bash'                           : [],
    '#SBATCH --mail-type=FAIL'              : [],
    '#SBATCH --mail-user='+email            : [],
    '#SBATCH --account=eel6763'             : [],
    '#SBATCH --qos=eel6763'                 : [],
    '#SBATCH --nodes='                      : [8,8,8], # Fill this
    '#SBATCH --ntasks='                     : [8,8,8], # Fill this
    '#SBATCH --ntasks-per-node='            : [1,1,1], # Fill this
    '#SBATCH --cpus-per-task=1'             : [],
    '#SBATCH --mem-per-cpu=500mb'           : [],
    '#SBATCH -t 00:05:00'                   : [],
    '#SBATCH -o '+outfile_prefix            : list(range(job_count)),
    '#SBATCH -e '+errfile_prefix            : list(range(job_count)),
    slurmrun_cmd                            : [10,20,21], # Fill this
    }

# Outputs we wish to track (MUST be in form Foo=X where X is floating point data to be captured)
outputs_dict =   { 
                "Time" : [],
                "Cycles" : []
                }

def genSlurmCmds(sbatch_cmds_dict : dict, job_count : int):
    # This function converts the vectorized dictionary into individual string arrays to be written to slurm files
    
    slurm_cmds_arr = [[]]*job_count
    
    for i in range(job_count):
        cmd_str_arr = []
        for cmd in sbatch_cmds_dict:

            if(sbatch_cmds_dict[cmd]): cmd_str_arr.append(cmd+str(sbatch_cmds_dict[cmd][i]))
            else: cmd_str_arr.append(cmd)
            
        slurm_cmds_arr[i] = cmd_str_arr

    return slurm_cmds_arr

def genSlurmFile(cmds, path : str):
    with open (path, 'w+') as slurmf: 
        for cmd in cmds:
            slurmf.write(cmd + '\n')

    os.chmod(path, 0o744)


def executeSlurmFile(job_dir, job_name):
    slurm = subprocess.run(['./'+job_name], cwd=job_dir, stdout=subprocess.PIPE, encoding='utf-8') # Should return once complete I think
    slurm.check_returncode() # Ensures process ran and exited properly
    
    output_text = slurm.stdout
    #print(output_text)
    return output_text

def parseOutputText(text: str, out_dict: str):

    lines = text.splitlines()

    for key in out_dict:
        for line in lines:
            if key in line:
                temp = line.split(key)[1]
                temp = temp.replace('=','')
                out_dict[key].append(float(temp))
    
    print(out_dict)


### TEST SETUP ###

slurm_cmds_arr = genSlurmCmds(sbatch_cmds_dict, job_count)

for slurm_cmds in slurm_cmds_arr:
    genSlurmFile(slurm_cmds, job_path)
    output_text = executeSlurmFile(job_directory, job_file_name)
    parseOutputText(output_text, outputs_dict)


