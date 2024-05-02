#!/bin/bash
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=caleb.bean@ufl.edu
#SBATCH --account=eel6763
#SBATCH --qos=eel6763
#SBATCH --nodes=1
#SBATCH --ntasks=16
#SBATCH --ntasks-per-node=16
#SBATCH --cpus-per-task=16
#SBATCH --mem-per-cpu=500mb
#SBATCH -t 00:20:00
#SBATCH -o lulesh_out4
#SBATCH -e lulesh_err4
export OMP_NUM_THREADS=16
srun ./lulesh2.0 -i 50 -s 30
