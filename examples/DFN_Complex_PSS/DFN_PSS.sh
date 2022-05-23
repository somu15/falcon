#!/bin/bash
#PBS -M Som.Dhulipala@inl.gov
#PBS -m abe
#PBS -N DFN_PSS_Complex
#PBS -P forge
#PBS -l select=25:ncpus=40:mpiprocs=40
#PBS -l walltime=80:00:00

JOB_NUM=${PBS_JOBID%%\.*}

cd $PBS_O_WORKDIR

\rm -f out
date > out

MV2_ENABLE_AFFINITY=0 mpiexec ~/projects/falcon/falcon-opt -i Main_Box_PSS.i >> out

date >> out
