#dir=Directory in which input files can be found

dir=$1
count=1

for D in `find $dir -maxdepth 1 -mindepth 1 -type d`
do

	#echo $D
	cd $D
	ID="$(basename $D)"
	Barcode="$(sed "${count}q;d" ../Barcodes_for_MSG.txt)"

	out="indiv${ID}_$Barcode.gz"
	echo $out	
	cat NG-9974*_val_*.fq | gzip -c - > $out
	mv $out /storageNGS/ngs4/projects/other/Sporisorium_Reilianum_Virulence/SequenceAnalysis/Recombination_Analysis/MSG/data/
	#echo "$Barcode	${ID}"
	gzip *fastq
	gzip *fq
	cd ../../
	count=$((count + 1))

done
