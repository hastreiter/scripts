GFF="/storageNGS/ngs4/projects/other/Sporisorium_Reilianum_Virulence/Annotation/p3_t72559_Spo_reili_v2.gff3"
SCRIPTDIR="/storageNGS/ngs4/projects/other/HostJump_Bromivora_Brachypodium/WGS/Hybrids/HFS_Pipeline/scripts"

#printf "#STEP 5:\tConverting target GFF to GTF\t\t\t"
classes="3utr 5utr exon mRNA"


#for class in $classes
#do
#        grep -P "\t$class\t" $GFF > ${GFF%.gff3}.$class.gff3

#        /storageNGS/ngs1/software/gffread-0.9.9.Linux_x86_64/gffread ${GFF%.gff3}.$class.gff3 -O -F -T -o ${GFF%.gff3}.$class.gtf

#        rm ${GFF%.gff3}.$class.gff3

#        sed -i -e "s/\texon\t/\t$class\t/g" ${GFF%.gff3}.$class.gtf

#        perl $SCRIPTDIR/fixGTF.pl ${GFF%.gff3}.$class.gtf
#        rm ${GFF%.gff3}.$class.gtf
#        mv ${GFF%.gff3}.$class.fixed.gtf ${GFF%.gff3}.$class.gtf
        
#       sed -i -e "s/\t$class\t/\tfeature\t/g" ${GFF%.gff3}.$class.gtf
#done

#cat ${GFF%.gff3}.3utr.gtf ${GFF%.gff3}.5utr.gtf ${GFF%.gff3}.exon.gtf ${GFF%.gff3}.mRNA.gtf > ${GFF%.gff3}.FeatureCountReady.gtf

D="/storageNGS/ngs4/projects/other/Sporisorium_Reilianum_Virulence/SequenceAnalysis/data"

bams=$(find $D -name *MD.bam) 
arr=($(echo $bams | tr "" "\n"))
bams2=$( IFS=" " ; echo "${arr[*]}" )

/storageNGS/ngs1/software/subread-1.4.6-Linux-x86_64/bin/featureCounts -T 40 -g feature_id -t feature -f -p -B -a ${GFF%.gff3}.FeatureCountReady.gtf -o /home/ibis/hastreiter/Sporisorium_Reilianum_Virulence/SequenceAnalysis/FeatureCount/FeatureCount.out $bams2


