#!/usr/bin/perl
# add_uniqIDs2fasta.pl
use strict; use warnings;
use Getopt::Long;

# This script takes ONE required argument: a FASTA file
# Use this script to add a uniq ID (count number) to each sequence header

my $usage = "\n\tadd_uniqIDs2fasta.pl [-h -o -q] -i <FASTA>\n\n";

# defaults
my $help;
my $outDir = './';
my $quiet;
my $inFile;

GetOptions (
	'help!'  => \$help,
	'quiet!' => \$quiet,
	'o=s'    => \$outDir,
	'i=s'    => \$inFile,
	) or die $usage;

die $usage unless $help or $inFile;
if ($outDir !~ /\/$/) {$outDir = "$outDir\/"}

if ($help) {print $usage} 
else {
	my ($outName) = $inFile =~ /(\S+)\.fas*t*a*$/;
	my $outFile = "${outDir}${outName}.IDed.fasta";
	open INF, "<$inFile" or die "\n\tError: cannot open $inFile\n\n";
	open OUT, ">$outFile" or die "\n\tError: cannot create $outFile\n\n";

	my $seqCount = 0;
	while (<INF>) {
		if ($_ =~ /^\>/) {
			$seqCount++;
			unless ($quiet) {
				if ($seqCount % 10000 == 0) {
					$|++;
					print "\r\tseqs:\t$seqCount";
				}
			}
			my $hdr = $_;
			my $seq = <INF>;
			chomp ($hdr, $seq);
			print OUT "$hdr-$seqCount\n$seq\n";
		}
	}
	print "\r\tseqs:\t$seqCount\n\n" unless $quiet;
	close INF; close OUT;
}