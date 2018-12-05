#!/usr/bin/perl -w
#title           :exomeCapture.pl
#description     :
#author          :
#date            :20130423
#version         :0.1    
#usage           :perl exomeCapture.pl
#notes           :
#==============================================================================

use strict;
use warnings;
use Getopt::Long; 
use File::Find::Rule;

###############################################################################
				#Global constants
###############################################################################
my $DATA_DIR="/tmp";


###############################################################################
				#Usage and arguments
###############################################################################



sub findFiles{
	my @files = File::Find::Rule->file()
                              #->name( qr/.*filtered_aln_noDups_realigned_recal$/ )	
                              #->name( qr/.*docOut$/ )
                              ->name( qr/.*.CaptureCov$/ )
				->in( $DATA_DIR );
	print join("\n", @files);
	print "\n";
	return(@files);	
}



sub runner{
	my $filesToFind = "coverage.txt";
	my @perc;

	my @infiles = findFiles("$filesToFind");
		print("Starting...\n");
	open (RUN, ">exome_capture.csv");
	print RUN "Coverage";	
	for(my $i=0;$i<scalar(@infiles);$i++){
		print("Analysing file: $infiles[$i]\n");
		print RUN "\t$infiles[$i]";
		open (TMP,"<",$infiles[$i]);
			my $line = "";
			my %hash = ();
			my $totalBasePairs = 0;
			while(<TMP>){
				$line=$_;
				$totalBasePairs++;
				if($totalBasePairs % 1000000 == 0){
					print("Processed $totalBasePairs lines...\n");
				}
				my @fields = split(/\t/,$line);
				my $coverage = $fields[3];
				chomp($coverage);
				if(exists($hash{$coverage})){
					$hash{$coverage}++;
				}else{
					$hash{$coverage} = 1;
				}			
			}
#			
#
#		#Iterate hash and calculate %
#
		for(my $j=0;$j<=100;$j++){
			my $above = 0;
			my $under = 0;
			for my $cov ( keys %hash) {
				if($cov>=$j){
					$above+=$hash{$cov};
				}#else{
#					$under+=$hash{$cov};
#				}			
			}
			my $percentage = $above/$totalBasePairs*100;
			print("Coverage: $j	$percentage%\n");
			$perc[$j] .= "\t$percentage";
		}
		print("-----------------------------\n");

		close(TMP);
	}
	print RUN "\n";
	for(my $l=0;$l<=100;$l++){
		print RUN "$l$perc[$l]\n";
	}
	close(RUN);
}


runner();
#findFiles();
