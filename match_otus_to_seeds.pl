#!/usr/bin/perl
# match_otus_to_seeds.pl
use strict; use warnings;
use Getopt::Long;

# Use this script to get the seed sequences for each OTU in an OTU table from a single fasta file containing all OTU seed sequences

my $usage = "\n\tmatch_otus_to_seeds.pl [-h -o -i <OTU TABLE> -b <\"regex for batch processing OTU TABLES\">] -f <FASTA file> \n\n";

# defaults
my $help;
my $outDir = './';
my $inFile;
my $batch;
my $fastaFile;

GetOptions (
	'help!' => \$help,
	'o=s'   => \$outDir,
	'i=s'   => \$inFile,
	'b=s'   => \$batch,
	'f=s'   => \$fastaFile,
	) or die $usage;

die $usage unless $help or ($fastaFile and ($inFile or $batch));
if ($outDir !~ /\/$/) {$outDir = "$outDir\/"}

if ($help) {print $usage}
else {
	# "global" variables
	my %seqs_by_otu;
	my @inFiles;

	if ($batch) {
		@inFiles = glob $batch;
	} else {
		push @inFiles, $inFile;
	}

	open FAF, "<$fastaFile" or die "\n\tError: cannot open $fastaFile\n\n";

	while (<FAF>) {
		if ($_ =~ /^\>/) {
			my ($otu) = /^\>(X\d+)/;
			my $seq = <FAF>;
			chomp ($seq);
			# print "$otu\n";
			$seqs_by_otu{$otu} = $seq;
		}
	}
	close FAF;

	foreach $inFile (@inFiles) {
		my ($fileName) = $inFile =~ /(.+\.otu)s\.txt/;
		my $outFile = "${outDir}${fileName}_seqs.fasta";

		open INF, "<$inFile" or die "\n\tError: cannot open $inFile\n\n";
		open OUT, ">$outFile" or die "\n\tError: cannot create $outFile\n\n";
		$_ = <INF>;

		while (<INF>) {
			my ($otu) = /^(X\d+)\t/;
			# print "$otu\n";
			print OUT ">$otu\n$seqs_by_otu{$otu}\n";
		}
		close INF; close OUT;
	}

}