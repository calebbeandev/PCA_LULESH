#!/bin/bash
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=caleb.bean@ufl.edu
#SBATCH --account=eel6763
#SBATCH --qos=eel6763
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=500mb
#SBATCH -t 00:05:00
#SBATCH -o lulesh_out1
#SBATCH -e lulesh_err1
srun ./lulesh2.0 -s 8
