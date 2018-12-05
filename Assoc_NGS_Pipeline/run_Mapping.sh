#!/bin/bash

#cat /storageNGS/ngs4/projects/other/Sporisorium_Reilianum_Virulence/SequenceAnalysis/SRS_based_Assoc/data/Fastq.list | while read p
cat /storageNGS/ngs4/projects/other/Sporisorium_Reilianum_Virulence/SequenceAnalysis/SRS_based_Assoc/data/Test.list | while read p
do

#NG-9974_TW99_lib131940_4751_5_2_val_2.fq
#NG-9974_TW107_lib131988_4752_8_1.fastq

	suffix="_1_val_1.fq.gz";
	#fwd=${p%$suffix}; #Remove suffix
	#fwd="${fwd}_1_val_1.fq";
	fwd=$p

	rev=${p%$suffix}; #Remove suffix
	rev="${rev}_2_val_2.fq.gz";
	
	dir="$(dirname $fwd)"		

	echo $fwd
	echo $rev

	/storageNGS/ngs4/projects/other/Sporisorium_Reilianum_Virulence/SequenceAnalysis/SRS_based_Assoc/scripts/Mapping_02.sh $fwd $rev

done
