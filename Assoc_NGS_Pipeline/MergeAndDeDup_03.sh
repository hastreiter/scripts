#dir=Directory in which input files can be found

#Merge and Dedup

dir=$1
bamout=""

for D in `find $dir -maxdepth 1 -mindepth 1 -type d`
do
    echo $D
    bams=$(find $D -name *.bam) 
    echo $bams
    bamarray=($bams)
    nBAM=${#bamarray[@]}
    if [ $nBAM -eq 1 ]
    then

	base=$PWD
	bam="$(basename ${bamarray[0]})"
	arr=($(echo $bam | tr "." "\n"))
	bamout="${arr[0]}.sorted.merged.bam"
	cd $D
	ln -s $bam $bamout
	cd $base
	bamout="$D/$bamout"

    elif [ $nBAM -gt 1 ] 
    then
	bam="$(basename ${bamarray[0]})"
	arr=($(echo $bam | tr "." "\n"))
	bamout="$D/${arr[0]}.sorted.merged.bam"
	
	for ((i=0;i<$nBAM;i++)); do
   	 bamarray[i]="I=${bamarray[i]}"
	done

	bams2=$( IFS=" " ; echo "${bamarray[*]}" )

	java -Xmx40g -jar /storageNGS/ngs1/software/picard-tools/picard-tools-2.18.3/picard.jar MergeSamFiles $bams2 O=$bamout SO=coordinate ASSUME_SORTED=true USE_THREADING=true

    else
	
	echo "Nothing to do..Empty folder." 

    fi

#After Merging,now Dedup	
	suffix=".bam";
	dedupOUT=${bamout%$suffix}; #Remove suffix
	dedupOUT="${dedupOUT}.MD.bam"
	dedupMatrix="${dedupOUT}.MD.matrix"


java -Xmx40g -jar /storageNGS/ngs1/software/picard-tools/picard-tools-2.18.3/picard.jar MarkDuplicates I=$bamout O=$dedupOUT M=$dedupMatrix REMOVE_DUPLICATES=false ASSUME_SORTED=true

done


