#!/usr/bin/perl
# quality_stats.pl
use strict; use warnings;

my @fqfiles = `ls *.fq *.fq_[12]`;	# get fastq files from the current directory and hold them in an array
chomp @fqfiles;
my $num_fqfiles = @fqfiles;			# get the number of fastq files in the directory
my $i = 0;
foreach my $fqfile (@fqfiles) { 	# run each file through fastx_quality_stats and output the quality stats summary to a .qual file
     my ($fqfiletag) = $fqfile =~ m/sample\_(\S+)/;
     system("fastx_quality_stats -i $fqfile -o $fqfiletag\.quals -Q 33");
     $i++;
     print "$i of $num_fqfiles fastq files completed\n";
}

my @qualfiles = `ls *.quals`;		# get the .qual files from the current directory and put them into an array
chomp @qualfiles;
my $num_qualfiles = @qualfiles;		# get the number of qual files in the directory
my $sum_mean_quals = 0;				# a variable to hold the sum of the quality scores from all lines of all qual files
my $quals_count = 0;				# a variable to hold the count of mean read quality scores
my $j = 0;
open(OUT, ">mean_qualities.txt");

foreach my $qualfile (@qualfiles) { # open each .qual file individually
     open(QUALS, "<$qualfile") or die "Error: cannot open one or more quality summary files";
     <QUALS>;

     while (my $line = <QUALS>) {	# get the mean read quality score from each line of the qual file (6th column)
          my ($mean_qual) = $line =~ m/\d+\t\d+\t\d+\t\d+\t\d+\t(\d{1,2}\.\d{2})/;
          $sum_mean_quals += $mean_qual; # add each mean quality score to the sum_mean_quals variable
          $quals_count++;
     }

     close(QUALS);
     $j++;
     print "$j of $num_qualfiles quality files completed\n";
     my $file_avg = $sum_mean_quals / $quals_count;
     print OUT "$qualfile average read qual: $file_avg\n";
}

my $mean_qual = $sum_mean_quals / $quals_count;	# divide the sum of mean quality score by the number of them for the overall mean

print "\n\tAverage read quality score: $mean_qual\n\n";
