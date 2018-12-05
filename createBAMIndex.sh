#!/bin/bash
#Creates index for bam files if not existing
filename=$1
while read p; do 
	if [ ! -e "${p}.bai" ]; then
		echo "Creating index for $p"
		echo "samtools index $p"
		samtools index $p		
	else
		echo "Index exists."
	fi 
done < $filename

