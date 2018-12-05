REF="/storageNGS/ngs4/projects/other/Sporisorium_Reilianum_Virulence/genomes/SRS.fa"
knownSNP="/storageNGS/ngs4/projects/other/Sporisorium_Reilianum_Virulence/SequenceAnalysis/SRS_based_Assoc/vcf/NoBQSR/AllSamples.filtered.SNPs.vcf"
knownINDEL="/storageNGS/ngs4/projects/other/Sporisorium_Reilianum_Virulence/SequenceAnalysis/SRS_based_Assoc/vcf/NoBQSR/AllSamples.filtered.Indels.vcf"


#dir="/storageNGS/ngs4/projects/other/Sporisorium_Reilianum_Virulence/SequenceAnalysis/data"

#for p in $(find $dir -iname '*.MD.bam'); do 
while read p; do
	echo "$p"
	suffix=".bam";
	out=${p%$suffix}; #Remove suffix
	out_bam="${out}.recal.bam"
	out_recal_data="${out}.recal_data.table"
	out_post_recal_data="${out}.post_recal_data.table"
	out_plots="${out}.recalibration_plots.pdf"
	out_gvcf="${out}.recal.raw.snps.indels.g.vcf"

	java -Xmx40g -jar /storageNGS/ngs1/software/GATK/GenomeAnalysisTK-3.8-1-0-gf15c1c3ef/GenomeAnalysisTK.jar -T BaseRecalibrator -R $REF -I $p -knownSites $knownSNP -knownSites $knownINDEL -o $out_recal_data -nct 12

	java -Xmx40g -jar /storageNGS/ngs1/software/GATK/GenomeAnalysisTK-3.8-1-0-gf15c1c3ef/GenomeAnalysisTK.jar -T BaseRecalibrator -R $REF -I $p -knownSites $knownSNP -knownSites $knownINDEL -BQSR $out_recal_data -o $out_post_recal_data -nct 12

	java -Xmx40g -jar /storageNGS/ngs1/software/GATK/GenomeAnalysisTK-3.8-1-0-gf15c1c3ef/GenomeAnalysisTK.jar -T AnalyzeCovariates -R $REF -before $out_recal_data -after $out_post_recal_data -plots $out_plots

	java -Xmx40g -jar /storageNGS/ngs1/software/GATK/GenomeAnalysisTK-3.8-1-0-gf15c1c3ef/GenomeAnalysisTK.jar -T PrintReads -R $REF -I $p -BQSR $out_recal_data -o $out_bam  -nct 12

	samtools index $out_bam

	java -Xmx40g -jar /storageNGS/ngs1/software/GATK/GenomeAnalysisTK-3.8-1-0-gf15c1c3ef/GenomeAnalysisTK.jar -R $REF -T HaplotypeCaller -nct 12 -I $out_bam --emitRefConfidence GVCF -o $out_gvcf -maxAltAlleles 10
done <$1
