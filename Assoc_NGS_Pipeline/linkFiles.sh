dir="/storageNGS/ngs4/projects/other/Sporisorium_Reilianum_Virulence/SequenceAnalysis/SRZ_based_Assoc/data"
dest="/storageNGS/ngs4/projects/other/Sporisorium_Reilianum_Virulence/SequenceAnalysis/SRS_based_Assoc/data"

for D in `find $dir -maxdepth 1 -mindepth 1 -type d`
do

	ID="$(basename $D)"

	cd /storageNGS/ngs4/projects/other/Sporisorium_Reilianum_Virulence/SequenceAnalysis/SRS_based_Assoc/data/$ID/
	echo $PWD
	cp -s /storageNGS/ngs4/projects/other/Sporisorium_Reilianum_Virulence/SequenceAnalysis/SRZ_based_Assoc/data/$ID/*fq.gz .

done
