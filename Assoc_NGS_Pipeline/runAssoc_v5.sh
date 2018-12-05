#Perform association analysis

#TODO before running
#1: Check tests var for test to be performed 
#3: Check pheno var to ensure correct pheno file is used
#3: Check Pval adjust method
#4: Check Pval for BH correction

ScriptPath="/storageNGS/ngs4/projects/other/Sporisorium_Reilianum_Virulence/SequenceAnalysis/SRS_based_Assoc/Association_Analysis/scripts"

#1.PVAL-ADJUST-METHOD
ADJUST="BH"	#BH or BONF
Pval=0.01	#Used for BH only	

#2.ANALYSIS
Analysis="Sorghum_Virulence_Damaging"
#Analysis="Sorghum_Virulence"
#Analysis="Colony_Texture"
#Analysis="Colony_Texture_Damaging"
#Analysis="Greyscale_Damaging"
#Analysis="Virulence_Sorghum_Damaging"

#3.PHENO FILE
Pheno="/home/ibis/hastreiter/Sporisorium_Reilianum_Virulence/comparison_on_sorghum_and_phenotypes.csv"								#Sorghum_Virulence
#Pheno="/home/ibis/hastreiter/Sporisorium_Reilianum_Virulence/phenotypes_comparison-for_max.ColonyTexture.csv"							#Colony_Texture
#Pheno="/home/ibis/hastreiter/Sporisorium_Reilianum_Virulence/phenotypes_comparison-for_max.Greyscale.csv"							#Greyscale
#Pheno="/storageNGS/ngs4/projects/other/Sporisorium_Reilianum_Virulence/SequenceAnalysis/SRS_based_Assoc/Association_Analysis/Info/virulnce_on_sorghum.csv"	#Virulence_Sorghum_Damaging

#4.GROUP TESTS
#tests=("G1G2vsG3" "G1vsG2" "G1vsG2G3" "G4vsG5" "G4vsG5G6" "G4vsG6" "G5vsG6" "G7vsG8" "G7vsG9" "G7G8vsG9" "G10vsG11" "G10vsG13" "G12vsG13" "G11vsG12")		#Sorghum_Virulence
#tests=("G1vsG2" "G1vsG3" "G1vsG4" "G1vsG5" "G1vsG6" "G2vsG3" "G2vsG4" "G2vsG5" "G2vsG6" "G3vsG4" "G3vsG5" "G3vsG6" "G4vsG5" "G4vsG6" "G5vsG6")			#Colony_Texture & Greyscale
#tests=("G1vsG2" "G1vsG3" "G2vsG3")																#Virulence_Sorghum_Damaging
tests=("G1vsG4" "G2vsG4")
	
#5.VCF
VCF="/storageNGS/ngs4/projects/other/Sporisorium_Reilianum_Virulence/SequenceAnalysis/SRS_based_Assoc/Association_Analysis/data/AllSamples.filtered.SNPs.vcf"

				
#############################################################################################################################################################

#Create PED Files and Folders if necessary
Rscript $ScriptPath/createGroupPEDs_v2.R $Analysis $Pheno ${tests[*]}


cd $Analysis

#First annotate and filter the VCF if required

if [[ $Analysis == *_Damaging ]]; then
	if [ ! -f AllSamples.SNP.filtered.lifted.ann.vcf ]; then
	java -jar /storageNGS/ngs1/software/snpEff_v4.3q/snpEff.jar -s AllSamples.SNP.filtered.lifted.ann.html SRS $VCF > AllSamples.SNP.filtered.lifted.ann.vcf

	java -jar /storageNGS/ngs1/software/snpEff_v4.3q/SnpSift.jar filter "(ANN[*].EFFECT has 'missense_variant') | (ANN[*].EFFECT has 'stop_gained') |(ANN[*].EFFECT has 'stop_lost')"  	AllSamples.SNP.filtered.lifted.ann.vcf > AllSamples.SNP.filtered.lifted.ann.damaging.vcf
	fi
	VCF="../AllSamples.SNP.filtered.lifted.ann.damaging.vcf"
fi



for i in ${tests[@]}; do

Test=$i
cd $Test

#Create Test-specific VCF and re-code for plink
cut -f1 $Test.ped > $Test.samples
if [ ! -f $Test.vcf ]; then
    java -jar /storageNGS/ngs1/software/GATK/GenomeAnalysisTK-3.6/GenomeAnalysisTK.jar -T SelectVariants -R /storageNGS/ngs4/projects/other/Sporisorium_Reilianum_Virulence/genomes/SRS.fa -V $VCF -o $Test.vcf --sample_file $Test.samples -env --ALLOW_NONOVERLAPPING_COMMAND_LINE_SAMPLES
fi

/storageNGS/ngs4/projects/other/Sporisorium_Reilianum_Virulence/Plink1.9/plink --vcf $Test.vcf --out $Test --double-id --allow-extra-chr
Rscript $ScriptPath/fixPED.R $Test.fam ${Test}.ped
rm $Test.fam
ln -s ${Test}.adjusted.ped $Test.fam
/storageNGS/ngs4/projects/other/Sporisorium_Reilianum_Virulence/Plink1.9/plink --bfile $Test --noweb --allow-no-sex --allow-extra-chr --assoc --adjust --out $Test

#1.91677369e-7--> 0.05/260855



UpperTest="$(echo $Test | tr '[a-z]' '[A-Z]')"	
Group1=${UpperTest%VS*}
Group2=${UpperTest##*VS}
echo $Group1
echo $Group2
NVAR="$(grep -cv '#' $Test.vcf)"
echo $NVAR


#Generate Manhatten Plot and Target Coord Lists for candidate gene list
if [ $ADJUST = "BH" ]; then	
	echo $Pval

	Rscript $ScriptPath/manhatten_v2.R $Test.assoc $Test Assoc $Group1 $Group2 $Pval $NVAR $ADJUST
	cat Targets.1.tmp | sed 's/^[1-9]\t/chr0&/' | sed 's/^[1-9][1-9]\t/chr&/' > Targets.$Test.$Group1.coords
	cat Targets.2.tmp | sed 's/^[1-9]\t/chr0&/' | sed 's/^[1-9][1-9]\t/chr&/' > Targets.$Test.$Group2.coords
	rm Targets.1.tmp
	rm Targets.2.tmp

else
	Pval=$(awk "BEGIN {print (0.05)/$NVAR}")
	echo $Pval

	Rscript $ScriptPath/manhatten_v2.R $Test.assoc $Test Assoc $Group1 $Group2 $Pval $NVAR $ADJUST

	awk -v Pval="$Pval" 'BEGIN{OFS="\t" }{ if ($9 <= Pval && $5 >= $6) {print $1,$3} }' $Test.assoc | sed 's/^[1-9]\t/chr0&/' | sed 's/^[1-9][1-9]\t/chr&/' | sed 's/$/\t/g'> Targets.$Test.$Group2.coords
	awk -v Pval="$Pval" 'BEGIN{OFS="\t" }{ if ($9 <= Pval && $5 < $6) {print $1,$3} }' $Test.assoc | sed 's/^[1-9]\t/chr0&/' | sed 's/^[1-9][1-9]\t/chr&/' | sed 's/$/\t/g'> Targets.$Test.$Group1.coords

fi

	

#Filter VCF for signficant variants
grep "#" $Test.vcf > Targets.$Test.$Group2.vcf
grep "#" $Test.vcf > Targets.$Test.$Group1.vcf

grep -f Targets.$Test.$Group2.coords $Test.vcf >> Targets.$Test.$Group2.vcf
grep -f Targets.$Test.$Group1.coords $Test.vcf >> Targets.$Test.$Group1.vcf

#Annotate and filter vcf
java -jar /storageNGS/ngs1/software/snpEff_v4.3q/snpEff.jar -s Targets.$Test.$Group2.ann.html SRS Targets.$Test.$Group2.vcf  > Targets.$Test.$Group2.ann.vcf
java -jar /storageNGS/ngs1/software/snpEff_v4.3q/snpEff.jar -s Targets.$Test.$Group1.ann.html SRS Targets.$Test.$Group1.vcf  > Targets.$Test.$Group1.ann.vcf

java -jar /storageNGS/ngs1/software/snpEff_v4.3q/SnpSift.jar filter "(ANN[*].EFFECT has 'missense_variant') | (ANN[*].EFFECT has 'stop_gained') |(ANN[*].EFFECT has 'stop_lost')"  Targets.$Test.$Group2.ann.vcf > Targets.$Test.$Group2.ann.damaging.vcf
java -jar /storageNGS/ngs1/software/snpEff_v4.3q/SnpSift.jar filter "(ANN[*].EFFECT has 'missense_variant') | (ANN[*].EFFECT has 'stop_gained') |(ANN[*].EFFECT has 'stop_lost')"  Targets.$Test.$Group1.ann.vcf > Targets.$Test.$Group1.ann.damaging.vcf

#Prepare candidate lists
sed -i 's/#GeneName/GeneName/g'  Targets.$Test.$Group2.ann.genes.txt
sed -i 's/#GeneName/GeneName/g'  Targets.$Test.$Group1.ann.genes.txt

Rscript $ScriptPath/filterGenes.R Targets.$Test.$Group2.ann.genes.txt
Rscript $ScriptPath/filterGenes.R Targets.$Test.$Group1.ann.genes.txt

#	mkdir PCA
#	cd PCA
#	rm Targets.$Test.$Group2.ann.damaging.fam
#	/storageNGS/ngs4/projects/other/Sporisorium_Reilianum_Virulence/Plink1.9/plink --vcf ../Targets.$Test.$Group2.ann.damaging.vcf --out Targets.$Test.$Group2.ann.damaging --double-id --allow-extra-chr
#	rm Targets.$Test.$Group2.ann.damaging.fam
#	ln -s ../$Test.fam Targets.$Test.$Group2.ann.damaging.fam
#	/storageNGS/ngs4/projects/other/Sporisorium_Reilianum_Virulence/Plink1.9/plink --bfile Targets.$Test.$Group2.ann.damaging --pca 10 --out Targets.$Test.$Group2.ann.damaging.pca --allow-extra-chr
#	Rscript $ScriptPath/plotPCA.R Targets.$Test.$Group2.ann.damaging.pca.eigenvec Targets.$Test.$Group2.ann.damaging.fam $Test
#	cd ..

mkdir -p ~/Dropbox/Plots_New/SRS/$Analysis/$Test/$ADJUST/$Pval
cp *.png ~/Dropbox/Plots_New/SRS/$Analysis/$Test/$ADJUST/$Pval
cp *.Candidates.tsv ~/Dropbox/Plots_New/SRS/$Analysis/$Test/$ADJUST/$Pval

mkdir -p ../Results/$Test/$ADJUST/$Pval
cp * ../Results/$Test/$ADJUST/$Pval


cd ..

done

cd ..

exit 0
