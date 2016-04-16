#!/usr/bin/perl
# nt_bias.pl
use strict; use warnings;
use Getopt::Long;

# use this script to get a number of nucleotides from the beginning of unique sequences, sort, and multiply by their abundance (use with .csv files provided by Emily from V-QUEST results)

my $usage = "\n\tnt_bias.pl -n <num nts> -i <file>\n\n";

# defaults
my $nts;
my $infile;

GetOptions (
	'n=i' => \$nts,
	'i=s' => \$infile,
) or die $usage;

# global variables
my ($filename) = $infile =~ /(\S+)\.(txt|csv)$/;
my %subseq_abunds;
my $sum = 0;

open INF, "<$infile" or die "\n\tError: cannot open $infile\n\n";
open OUT, ">$filename.${nts}mer_cts.txt" or die "\n\tError: cannot create $filename.${nts}mer_cts.txt\n\n";

while (<INF>) {
	my ($seq)   = $_ =~ /^([ACGTN]+)\|/i;
	# print "$seq\n";
	my ($abund) = $_ =~ /^$seq\|[\w ]+\|(\d+)\|/i;

	$seq = uc $seq;
	my ($subseq) = $seq =~ /^([ACGTN]{$nts})/;
	

	$subseq_abunds{$subseq} += $abund;
	$sum += $abund;
} 

close INF;

my @subseqs = sort {$subseq_abunds{$b} <=> $subseq_abunds{$a}} keys %subseq_abunds;

open OUT, ">$filename.${nts}mer_cts.txt" or die "\n\tError: cannot create $filename.${nts}mer_cts.txt\n\n";
print OUT "sub.seq\tabs.abund\tpc.abund\n";

foreach my $subseq (@subseqs) {
	my $percent = $subseq_abunds{$subseq} / $sum;
	printf OUT "%s\t%d\t%.3f\n", $subseq, $subseq_abunds{$subseq}, $percent;
}

close OUT;