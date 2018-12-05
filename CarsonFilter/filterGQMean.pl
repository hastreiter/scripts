#!/usr/bin/perl
#title           :filterGQMean.pl
#description     :This script calculates the average GQ value for each site and removes the line if it falls below the specified cutoff
#author		 :Maximilian Hastreiter
#date            :20150702
#version         :0.1
#usage		 :perl filterGQMean.pl <INFILE> <Cutoff>
#==============================================================================


#Files
my $INFILE 	= $ARGV[0];
my $CUTOFF 	= $ARGV[1];

#Counters
my $processedLines	= 0;
my $filteredLines	= 0;
my $missingGTs		= 0;

open(INVCF,"<", $INFILE) or die "Can not open file $INFILE: $!";

my @INFILE_SPLIT = split(/.vcf/,$INFILE);

open(OUTVCF,">","$INFILE_SPLIT[0].GQMeanFiltered.vcf")  or die "Can not create file $INFILE_SPLIT[0].GQMeanFiltered.vcf: $!";

print "#Running filterGQMean.pl with Cutoff $CUTOFF\\n";
print "#Processing $INFILE\\n";
print "#Writing to $INFILE_SPLIT[0].GQMeanFiltered.vcf\\n";


#Iterate File
while(<INVCF>){
	my $line = $_;
	my @fields =split(/\t/,$line);
	if($line =~ m/^#.*/){#Print all Header lines
		print OUTVCF $line;
	}
	
	if(!($line =~ m/^#.*/)){ 	#Variant line	

		$processedLines++;

		my @line_fields =split(/\t/,$line);
		my $SumGQ = 0;
		my $SampleCount = 1;
		for(my $i=9;$i<scalar(@line_fields);$i++){
			if(!($line_fields[$i] =~ m/^\..*/)){	#Skip ./. entries

				my $sample_line = $line_fields[$i];
				my @anno_fields =split(/:/,$sample_line);
				my $GQ = $anno_fields[3];

				$SumGQ = $SumGQ + $GQ;
				$SampleCount++;

			}else{#end skip ./.
				#print "$line_fields[$i]\n";
				$missingGTs = $missingGTs + 1 ;			
	
			}
			
		}#end for
			
		my $MeanGQ = $SumGQ/$SampleCount;
		#print "$MeanGQ\n";

		if($MeanGQ >= $CUTOFF){
			print OUTVCF $line;
		}else{

			$filteredLines++;
		
		}

	    }#end if variant line

}#end while
					     
print "#Processed $processedLines variants\\n";	
print "#Found $missingGTs missing genotypes\\n";	
print "#Filtered $filteredLines variants due to GQMean < $CUTOFF\\n";			  



close(INVCF);
close(OUTVCF);
