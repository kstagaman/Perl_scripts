#!/usr/bin/perl
# good_samples.pl
use strict; use warnings;
use Getopt::Long;

# Use this script to get the names of samples with median seq length of the appropriate size from a seq_stats.pl output file

my $usage = "\n\tgood_samples.pl [-h -o <output PATH>] -i <input TXT> -m <min INT>\n\n";

# defaults
my $help;
my $outDir = './';
my $inFile;
my $minMed = 250;

GetOptions (
	'help!' => \$help,
	'o=s'   => \$outDir,
	'i=s'   => \$inFile,
	'm=i'   => \$minMed,
	) or die $usage;

if ($outDir !~ /\/$/) {$outDir = "$outDir\/"}
die unless $help or $inFile;

if ($help) {
	help_txt();
}
else {
	my ($outname) = $inFile =~ /(\w+)\.txt/;
	my $outFile = "${outDir}${outname}_goodSamples.txt";
	open INF, "<$inFile" or die "\n\tError: cannot open $inFile\n\n";
	open OUT, "<$outFile" or die "\n\tError: cannot create $outFile\n\n";
	my $sampleFile;

	while(<INF>) {
		if($_ =~ /\:$/) {
			($sampleFile) = /(\S+)\:/;
		}
		if ($_ =~ /med seq/) {
			my ($seqLen) = /(\d+\.*\d*)$/;
			if ($seqLen >= $minMed) {
				print OUT "$sampleFile\n";
			}
		}
	}
}

sub help_txt {
	print $usage;
}