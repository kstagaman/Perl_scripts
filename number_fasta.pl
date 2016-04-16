#!/usr/bin/perl
# number_fasta.pl
use strict; use warnings;
use Getopt::Long;

# use this script to number sequences in a FASTA file, replacing all current headers

my $usage = "\t\nnumber_fasta.pl [-h -o <output PATH>] -i <FASTA file>\n\n";

# defaults
my $help;
my $outDir = './';
my $inFile;

GetOptions (
	'help!' => \$help,
	'o=s'   => \$outDir,
	'i=s'   => \$inFile,
	) or die $usage;

die $usage unless $help or $inFile;
if ($outDir !~ /\/$/) {$outDir = "$outDir\/"}

if($help) {print $usage}
else {
	my ($fileName) = $inFile =~ /^(.+)\.fasta$/;
	my $outFile = "${outDir}${fileName}.numbered.fasta"; 
	my $count = 0;

	open INF, "<$inFile" or die "\n\tError: cannot open $inFile\n\n";
	open OUT, ">$outFile" or die "\n\tError: cannot create $outFile\n\n";

	while (<INF>) {
		if ($_ !~ /^\>/) {
			$count++;
			my $seq = $_;
			chomp $seq;

			print OUT "\>$count\n$seq\n";
		}
	}
	close INF; close OUT;

}