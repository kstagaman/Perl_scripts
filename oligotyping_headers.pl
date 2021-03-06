#!/usr/bin/perl
# oligotyping_headers.pl
use strict; use warnings;
use Getopt::Long;

# use this script to change FASTA file headers to the appropriate syntax for the oligotyping pipeline

my $usage = "\n\toligotyping_headers.pl [-h -o <out PATH>] -i <input FASTA>\n\n";

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

if ($help) {print $usage}
else {
	# global variables
	my ($smpl) = $inFile =~ /^([\w+\-]+)\./i;
	# print "$smpl\n";
	my ($outName) = $inFile =~ /(.+)\.fa*s*t*a$/;
	my ($extension) = $inFile =~ /\.(fa*s*t*a)$/;
	my $count = 0;

	open INF, "<$inFile" or die "\n\tError: cannot open $inFile\n\n";
	open OUT, ">${outDir}$outName.oligoHeaders.$extension" or die "\n\tError: cannot create ${outDir}$outName.oligoHeaders.$extension\n\n";

	while (<INF>) {
		if ($_ =~ /^\>/) {
			$count++;
			my $seq = <INF>;
			chomp $seq;
			print OUT "\>Sample-${smpl}_Read$count\n$seq\n";
		}
	}
	close INF; close OUT;
}