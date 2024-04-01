#!/bin/bash
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=caleb.bean@ufl.edu
#SBATCH --account=eel6763
#SBATCH --qos=eel6763
#SBATCH --nodes=8
#SBATCH --ntasks=8
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=500mb
#SBATCH -t 00:05:00
#SBATCH -o lulesh_out
#SBATCH -e lulesh_err
srun ./lulesh2.0 -i 10 -s 4