#!/bin/bash

#$ -N jobname
#$ -cwd

# Need to count the number of files in the input directory
# use the following to count the number of .ndf files in a directory
#
# ls -1 /exports/eddie/scratch/testIris/input/JF110/*.ndf | wc -l
#
# then set the task range from 1 to the number of files (154 in this example):
#$ -t 1-124
# Maximum of 4 GB RAM (tests on 2 .ndf files show it's using ~ 0.5 GB so this should be enough)
#$ -l h_vmem=4G
# Maximum runtim of 1 hour (test show a single .ndf takes ~80 seconds)
#$ -l h_rt=01:00:00

# The directory we want to process with this job - change this as needed
SUBDIR=CDKL5_358

# Path to lwdaq executable
LWDAQ=/exports/cmvm/eddie/sbms/groups/Oren/lwdaq/LWDAQ/lwdaq

# Base input and output directories
INPUT_BASE_DIR=/exports/cmvm/eddie/sbms/groups/Oren/Data/Neurarchiver/CDKL5
OUTPUT_BASE_DIR=/exports/cmvm/eddie/sbms/groups/Oren/Data/Neurarchiver/CDKL5_SCPP4V2_output

# Input and output directories
INPUT_DIR=${INPUT_BASE_DIR}/${SUBDIR}
#The M subdirectory
MSUBDIR=$(ls -1 ${INPUT_DIR}/*.ndf | sed -n ${SGE_TASK_ID}p | awk -F "/" '{print $12}')
OUTPUT_DIR=${OUTPUT_BASE_DIR}/${SUBDIR}/${MSUBDIR}

# Location of the config files
CONFIG_DIR=/exports/cmvm/eddie/sbms/groups/Oren/Data/Neurarchiver/CDKL5_SCPP4V2_output/CDKL5_358
# Make output directory if it doesn't already exist
mkdir -p ${OUTPUT_DIR}

# Copy config files to output dir (lwdaq writes its output to the directory where the config files live)
cp ${CONFIG_DIR}/*.tcl ${OUTPUT_DIR}

# Location of the config files in the output directory
CONFIG1=${OUTPUT_DIR}/config.tcl
CONFIG2=${OUTPUT_DIR}/SCPP4V2.tcl

# Get input file that this task will process
# this gets the n'th file in the input directory, where n = $SGE_TASK_ID
INPUT_FILE=$(ls -1 ${INPUT_DIR}/*.ndf | sed -n ${SGE_TASK_ID}p)

# Run lwdaq on this task's input file
${LWDAQ} --pipe ${CONFIG1} ${CONFIG2} ${INPUT_FILE}

