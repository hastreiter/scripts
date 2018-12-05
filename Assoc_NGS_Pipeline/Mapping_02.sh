fwd=$1
rev=$2
REF="/storageNGS/ngs4/projects/other/Sporisorium_Reilianum_Virulence/genomes/SRS.fa"

#Get Read Groups

#NG-9974_TW99_lib131940_4751_5_2_val_2.fq
#@SCRAT:481:C86BPANXX:5:1101:1414:2182 1:N:0:CTGAAGCTGTACTGAC

file="$(basename $fwd)"
arr=($(echo $file | tr "_" "\n"))
SM=${arr[1]}
PL="ILLUMINA"
LB=${arr[2]}
dir="$(dirname $fwd)"
extrID=${arr[3]}

readName="$(zless $fwd | head -n 1)"
arr2=($(echo $readName | tr ":" "\n"))

FLOWCELL=${arr2[2]}
LANE=${arr2[3]}
PU=$FLOWCELL.$extrID.$LANE.$SM
ID=$FLOWCELL.$LANE

readGroup="@RG\tID:$ID\tPU:$PU\tSM:$SM\tPL:$PL\tLB:$LB"

echo $readGroup

OUT="$dir/${arr[0]}_${arr[1]}.$extrID.$LANE.sorted.bam"

echo $OUT

echo "/storageNGS/ngs1/software/bwa-0.7.17/bwa mem -t 40 -R $readGroup $REF $fwd $rev | java -Xmx40g -jar /storageNGS/ngs1/software/picard-tools/picard-tools-2.18.3/picard.jar SortSam I=/dev/stdin O=$OUT SO=coordinate CREATE_INDEX=true"
/storageNGS/ngs1/software/bwa-0.7.17/bwa mem -t 40 -R $readGroup $REF $fwd $rev | java -Xmx40g -jar /storageNGS/ngs1/software/picard-tools/picard-tools-2.18.3/picard.jar SortSam I=/dev/stdin O=$OUT SO=coordinate
