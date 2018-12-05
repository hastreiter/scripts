fwd=$1
rev=$2
out=$3

echo $fwd
echo $rev
echo $out

/storageNGS/ngs1/software/TrimGalore-0.4.5/trim_galore --paired --fastqc --path_to_cutadapt /storageNGS/ngs1/software/TrimGalore-0.4.5/cutadapt -o $out $fwd $rev
