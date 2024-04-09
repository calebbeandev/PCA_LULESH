#!/bin/bash
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=caleb.bean@ufl.edu
#SBATCH --account=eel6763
#SBATCH --qos=eel6763
#SBATCH --nodes=
#SBATCH --ntasks=
#SBATCH --ntasks-per-node=
#SBATCH --cpus-per-task=
#SBATCH --mem-per-cpu=500mb
#SBATCH -t 00:05:00
#SBATCH -o lulesh_out
#SBATCH -e lulesh_err
srun ./lulesh2.0 -s 
