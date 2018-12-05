#title           :runCarsonFilter.sh
#description     :This script applies all Filters proposed by Carson et at.
#author		 :Maximilian Hastreiter
#date            :20150706
#version         :0.1
#usage		 :sh runCarsonFilter.sh <INFILE>
#==============================================================================
#DEFAULT VALUES (change if required)

PATH_TO_FILTER_GQMEAN="Scripts/CarsonFilter/filterGQMean.pl"
PATH_TO_VCFTOOLS="Tools/vcftools_0.1.12b/"
PATH_TO_RSCRIPT="Scripts/CarsonFilter/plotFilterResults.R"
DP_CUTOFF=8
GQ_CUTOFF=20
GQ_MEAN_CUTOFF=35
CALL_RATE=0.88




INFILE=$1

#First Filter for DP and GQ

echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"
echo "%     Removing entries with DP<$DP_CUTOFF and GQ<$GQ_CUTOFF      %"
echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"

GQ_DP_OUTFILE=${INFILE/.vcf/.GQ_DPFilter}
$PATH_TO_VCFTOOLS/cpp/vcftools --vcf $INFILE --out $GQ_DP_OUTFILE --minGQ $GQ_CUTOFF --minDP $DP_CUTOFF --recode
GQ_DP_OUTFILE="$GQ_DP_OUTFILE.recode.vcf"



echo
echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"
echo "%     Removing variants with GQMEAN<$GQ_MEAN_CUTOFF          %"
echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"
echo
#Filter GQMEAN
STDOUT=$(perl $PATH_TO_FILTER_GQMEAN $GQ_DP_OUTFILE $GQ_MEAN_CUTOFF)
GQMEAN_OUTFILE=${GQ_DP_OUTFILE/.vcf/.GQMeanFiltered.vcf}
echo -e $STDOUT





#Get number of variants and correct pvalue cutoff for multiple testing
NumberOfVariants=`expr "$STDOUT" : '.*Processed \([0-9]*\) variants.*'`
NumberOfFiltered=`expr "$STDOUT" : '.*Filtered \([0-9]*\) variants.*'`
RemainingVariants=$((NumberOfVariants-NumberOfFiltered))
CorrectedPval=$(echo 0.05/$RemainingVariants | bc -l)

echo
echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"
echo "%     Removing variants with HWE Pval Cutoff $CorrectedPval   %"
echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"
echo


HWE_OUTFILE=${GQMEAN_OUTFILE/.vcf/.hwe}
$PATH_TO_VCFTOOLS/cpp/vcftools --vcf $GQMEAN_OUTFILE --hwe $CorrectedPval --out $HWE_OUTFILE --recode 
HWE_OUTFILE="$HWE_OUTFILE.recode.vcf"


echo
echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"
echo "%     Removing variants with Call Rate<$CALL_RATE             %"
echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"
echo

CALLRATE_OUTFILE=${HWE_OUTFILE/.recode.vcf/.callRate}
$PATH_TO_VCFTOOLS/cpp/vcftools --vcf $HWE_OUTFILE --out $CALLRATE_OUTFILE --recode --max-missing $CALL_RATE
CALLRATE_OUTFILE="$CALLRATE_OUTFILE.recode.vcf"

echo
echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"
echo "%     TS/TV Ratio                               %"
echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"
echo

echo "Input Variants"
Original_TSTV=$(cat $INFILE | $PATH_TO_VCFTOOLS/bin/vcf-tstv)
echo $Original_TSTV

echo "After DP,GQ Filtering"
GQ_DP_OUTFILE_TSTV=$(cat $GQ_DP_OUTFILE | $PATH_TO_VCFTOOLS/bin/vcf-tstv)
echo $GQ_DP_OUTFILE_TSTV

echo "After GQMean Filtering"
GQMEAN_OUTFILE_TSTV=$(cat $GQMEAN_OUTFILE | $PATH_TO_VCFTOOLS/bin/vcf-tstv)
echo $GQMEAN_OUTFILE_TSTV

echo "After HWE Filtering"
HWE_OUTFILE_TSTV=$(cat $HWE_OUTFILE | $PATH_TO_VCFTOOLS/bin/vcf-tstv)
echo $HWE_OUTFILE_TSTV

echo "After Call Rate Filtering"
CALLRATE_OUTFILE_TSTV=$(cat $CALLRATE_OUTFILE | $PATH_TO_VCFTOOLS/bin/vcf-tstv)
echo $CALLRATE_OUTFILE_TSTV


##Extract values for plotting
Original_TSTV_R=`expr "$Original_TSTV" : '^\([0-9]*\.[0-9]*\).*'`
GQ_DP_OUTFILE_TSTV_R=`expr "$GQ_DP_OUTFILE_TSTV" : '^\([0-9]*\.[0-9]*\).*'`
GQMEAN_OUTFILE_TSTV_R=`expr "$GQMEAN_OUTFILE_TSTV" : '^\([0-9]*\.[0-9]*\).*'`
HWE_OUTFILE_TSTV_R=`expr "$HWE_OUTFILE_TSTV" : '^\([0-9]*\.[0-9]*\).*'`
CALLRATE_OUTFILE_TSTV_R=`expr "$CALLRATE_OUTFILE_TSTV" : '^\([0-9]*\.[0-9]*\).*'`


Original_NVAR=`expr "$Original_TSTV" : '.*total=\([0-9]*\).*'`
GQ_DP_OUTFILE_NVAR=`expr "$GQ_DP_OUTFILE_TSTV" : '.*total=\([0-9]*\).*'`
GQMEAN_OUTFILE_NVAR=`expr "$GQMEAN_OUTFILE_TSTV" : '.*total=\([0-9]*\).*'`
HWE_OUTFILE_NVAR=`expr "$HWE_OUTFILE_TSTV" : '.*total=\([0-9]*\).*'`
CALLRATE_OUTFILE_NVAR=`expr "$CALLRATE_OUTFILE_TSTV" : '.*total=\([0-9]*\).*'`

PLOT_FILE=${INFILE/.vcf/.filter.pdf}
echo ""
echo "Generating Plot at $PLOT_FILE"
#Generate Plot
Rscript $PATH_TO_RSCRIPT $Original_TSTV_R $GQ_DP_OUTFILE_TSTV_R $GQMEAN_OUTFILE_TSTV_R $HWE_OUTFILE_TSTV_R $CALLRATE_OUTFILE_TSTV_R $Original_NVAR $GQ_DP_OUTFILE_NVAR $GQMEAN_OUTFILE_NVAR $HWE_OUTFILE_NVAR $CALLRATE_OUTFILE_NVAR $PLOT_FILE


echo "Done."

