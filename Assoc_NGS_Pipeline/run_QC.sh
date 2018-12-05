#!/bin/bash

#cat /home/ibis/hastreiter/Sporisorium_Reilianum_Virulence/SequenceAnalysis/data/FastQC_Batch1.txt | while read p
cat /storageNGS/ngs4/projects/other/Sporisorium_Reilianum_Virulence/SequenceAnalysis/SRS_based_Assoc/data/missedSample.txt | while read p
do
	fwd=$p
	suffix="_1.fastq";
	rev=${fwd%$suffix}; #Remove suffix
	rev="${rev}_2.fastq"		
	dir="$(dirname $fwd)"		

	echo $fwd
	echo $rev
	echo $dir
	/storageNGS/ngs4/projects/other/Sporisorium_Reilianum_Virulence/SequenceAnalysis/SRS_based_Assoc/scripts/QualityCheck_01.sh $fwd $rev $dir
	#qsub -q long_fed25 -l job_mem=4G -l hasStorageNGS -b y /home/ibis/hastreiter/Sporisorium_Reilianum_Virulence/SequenceAnalysis/QualityCheck.sh $fwd $rev $dir

done
