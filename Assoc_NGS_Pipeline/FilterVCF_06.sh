REF="/storageNGS/ngs4/projects/other/Sporisorium_Reilianum_Virulence/genomes/SRS.fa"
VCF="/storageNGS/ngs4/projects/other/Sporisorium_Reilianum_Virulence/SequenceAnalysis/SRS_based_Assoc/vcf/WithBQSR/AllSamples.raw.vcf"
SNP="/storageNGS/ngs4/projects/other/Sporisorium_Reilianum_Virulence/SequenceAnalysis/SRS_based_Assoc/vcf/WithBQSR/AllSamples.SNPs.vcf"
INDEL="/storageNGS/ngs4/projects/other/Sporisorium_Reilianum_Virulence/SequenceAnalysis/SRS_based_Assoc/vcf/WithBQSR/AllSamples.raw.Indels.vcf"
SNP_FILT="/storageNGS/ngs4/projects/other/Sporisorium_Reilianum_Virulence/SequenceAnalysis/SRS_based_Assoc/vcf/WithBQSR/AllSamples.filtered.SNPs.vcf"
INDEL_FILT="/storageNGS/ngs4/projects/other/Sporisorium_Reilianum_Virulence/SequenceAnalysis/SRS_based_Assoc/vcf/WithBQSR/AllSamples.filtered.Indels.vcf"

#Select
java -Xmx80g -jar /storageNGS/ngs1/software/GATK/GenomeAnalysisTK-3.8-1-0-gf15c1c3ef/GenomeAnalysisTK.jar -T SelectVariants -R $REF -V $VCF -selectType SNP -o $SNP
java -Xmx80g -jar /storageNGS/ngs1/software/GATK/GenomeAnalysisTK-3.8-1-0-gf15c1c3ef/GenomeAnalysisTK.jar -T SelectVariants -R $REF -V $VCF -selectType INDEL -o $INDEL

#Filter
java -Xmx80g -jar /storageNGS/ngs1/software/GATK/GenomeAnalysisTK-3.8-1-0-gf15c1c3ef/GenomeAnalysisTK.jar -T VariantFiltration -R $REF -V $SNP --filterExpression "QD < 2.0 || FS > 60.0 || MQ < 40.0 || MQRankSum < -12.5 || ReadPosRankSum < -8.0 || SOR > 3.0" --filterName "SNP_FILTER" -o "$SNP_FILT.tmp"
java -Xmx80g -jar /storageNGS/ngs1/software/GATK/GenomeAnalysisTK-3.8-1-0-gf15c1c3ef/GenomeAnalysisTK.jar -T VariantFiltration -R $REF -V $INDEL --filterExpression "QD < 2.0 || FS > 200.0 || ReadPosRankSum < -20.0 || SOR > 10.0" --filterName "INDEL_FILTER" -o "$INDEL_FILT.tmp"

#Remove non variants and filtered vars
java -Xmx80g -jar /storageNGS/ngs1/software/GATK/GenomeAnalysisTK-3.8-1-0-gf15c1c3ef/GenomeAnalysisTK.jar -T SelectVariants -R $REF -V "$SNP_FILT.tmp" -env -ef -o $SNP_FILT
java -Xmx80g -jar /storageNGS/ngs1/software/GATK/GenomeAnalysisTK-3.8-1-0-gf15c1c3ef/GenomeAnalysisTK.jar -T SelectVariants -R $REF -V "$INDEL_FILT.tmp" -selectType INDEL -o $INDEL_FILT

rm "$SNP_FILT.tmp"
rm "$INDEL_FILT.tmp"


