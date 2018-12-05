REF="/storageNGS/ngs4/projects/other/Sporisorium_Reilianum_Virulence/genomes/SRS.fa"
dir="/storageNGS/ngs4/projects/other/Sporisorium_Reilianum_Virulence/SequenceAnalysis/SRS_based_Assoc/gvcf_WithBQSR"

gvcf=$(find $dir -name *.g.vcf)
echo $gvcf
gvcfarray=($gvcf)
nGVCF=${#gvcfarray[@]}
for ((i=0;i<$nGVCF;i++)); do
   	 gvcfarray[i]="--variant ${gvcfarray[i]}"
done
gvcfs=$( IFS=" " ; echo "${gvcfarray[*]}" )

java -Xmx80g -jar /storageNGS/ngs1/software/GATK/GenomeAnalysisTK-3.8-1-0-gf15c1c3ef/GenomeAnalysisTK.jar -T GenotypeGVCFs -R $REF $gvcfs -o "$dir/AllSamples.raw.vcf" -nt 40



