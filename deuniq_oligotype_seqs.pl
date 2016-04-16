#!/usr/bin/perl
# deuniq_oligotype_seqs.pl
use strict; use warnings;
use Getopt::Long;

# Use this script to de-unique sequences to be used for oligotyping.

my $usage = "\n\tdeuniq_oligotype_seqs.pl [-h -o -a <abundance id STRING>] -f <input FASTA>\n\n";

# defaults
my $help;
my $outDir = './';
my $abundID = 'freq:';
my $inFile;

GetOptions (
	'help!' => \$help,
	'o=s'   => \$outDir,
	'a=s'   => \$abundID,
	'f=s'   => \$inFile,
	) or die $usage;

die $usage unless $help or $inFile;
if ($outDir !~ /\/$/) {$outDir = "$outDir\/"}

if ($help) {print $usage} 
else {
	my ($outName) = $inFile =~ /(.+)\.fasta/;
	my $outFile = "${outDir}${outName}_deuniq.fasta";
	my %read_counts;

	open INF, "<$inFile" or die "\n\tError: cannot open $inFile\n\n";
	open OUT, ">$outFile" or die "\n\tError: cannot create $outFile\n\n";

	while (<INF>) {
		if ($_ =~ /^\>/) {
			my ($smpl) = /^\>(\S+)_/;
			my ($abund) = /$abundID(\d+)/;
			# print "$abund\n";
			my $seq = <INF>;
			chomp $seq;

			for (my $i=0; $i < $abund; $i++) {
				$read_counts{$smpl}++;
				print OUT "\>${smpl}_$read_counts{$smpl}\n$seq\n";
			}
		}
	}
	close INF; close OUT;
}