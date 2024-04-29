#!/bin/bash
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=caleb.bean@ufl.edu
#SBATCH --account=eel6763
#SBATCH --qos=eel6763
#SBATCH --partition=hpg2-compute
#SBATCH --nodes=
#SBATCH --ntasks=64
#SBATCH --ntasks-per-node=64
#SBATCH --cpus-per-task=16
#SBATCH --mem-per-cpu=500mb
#SBATCH -t 00:20:00
#SBATCH -o lulesh_out6
#SBATCH -e lulesh_err6
export OMP_NUM_THREADS=16
srun ./lulesh2.0 -i 500 -s 32
