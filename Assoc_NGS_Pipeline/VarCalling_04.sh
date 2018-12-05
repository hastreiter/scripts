dir=$1

REF="/storageNGS/ngs4/projects/other/Sporisorium_Reilianum_Virulence/genomes/SRS.fa"

for file in $(find $dir -iname '*.MD.bam'); do 
	echo "$file"
	suffix=".bam";
	out=${file%$suffix}; #Remove suffix
	out="${out}.raw.snps.indels.g.vcf"
	samtools index $file
	echo "java -Xmx40g -jar /storageNGS/ngs1/software/GATK/GenomeAnalysisTK-3.8-1-0-gf15c1c3ef/GenomeAnalysisTK.jar -R $REF -T HaplotypeCaller -nct 40 -I $file --emitRefConfidence GVCF -o $out -maxAltAlleles 10"
	java -Xmx40g -jar /storageNGS/ngs1/software/GATK/GenomeAnalysisTK-3.8-1-0-gf15c1c3ef/GenomeAnalysisTK.jar -R $REF -T HaplotypeCaller -nct 40 -I $file --emitRefConfidence GVCF -o $out -maxAltAlleles 10

done
