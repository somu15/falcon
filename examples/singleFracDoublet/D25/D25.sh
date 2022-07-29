#!/bin/bash
#PBS -M Som.Dhulipala@inl.gov
#PBS -m abe
#PBS -N D25
#PBS -P forge
#PBS -l select=5:ncpus=40:mpiprocs=40
#PBS -l walltime=48:00:00

JOB_NUM=${PBS_JOBID%%\.*}

cd $PBS_O_WORKDIR

\rm -f out
date > out

MV2_ENABLE_AFFINITY=0 mpiexec ~/projects/falcon/falcon-opt -i LHS.i >> out

date >> out