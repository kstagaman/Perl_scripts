#!/usr/bin/perl
# compare_unmatched_bcs.pl
use strict; use warnings;
use Getopt::Long;
use String::Approx 'adistr';

my $usage = "\n\tcompare_unmatched_bcs.pl [-h -q -o] -b <expected barcode TSV> -i <recovered unmatched barcode TSV\n\n";

# defaults
my $help;
my $quiet;
my $outdir = './';
my $bcFile;
my $inFile;

GetOptions (
	'help!'  => \$help,
	'quiet!' => \$quiet,
	'o=s'    => \$outdir,
	'b=s'    => \$bcFile,
	'i=s'    => \$inFile,
	) or die $usage;

if ($outdir !~ /\/$/) {$outdir = "$outdir\/"}
die unless $help or ($bcFile and $inFile);

if ($help) {help_txt()}
else {
	# global variables
	my %expBcSmpls;
	my @expBc1s;
	my @expBc2s;
	my ($name) = $inFile =~ /\/(.+)\.txt$/;
	my $lineCount = 0;

	$|++; print "Grabbing expected barcodes..." unless $quiet;
	open EBC, "<$bcFile" or die "\n\tError: cannot open $bcFile\n\n";
	while (<EBC>){
		my ($smpl) = /^(\w+)\t/;
		my ($ebc1) = /^$smpl\t([ACGTN]+)\t/;
		my ($ebc2) = /\t([ACGTN]+)$/;
		# print "$smpl\t$ebc1\t$ebc2\n";

		push @expBc1s, $ebc1;
		push @expBc2s, $ebc2;
		$expBcSmpls{"$ebc1\t$ebc2"} = $smpl;
	}
	close EBC;
	$|++; print "done\n" unless $quiet;

	open OUT, ">${outdir}$name.best_bc_matches.txt" or die "\n\tError: cannot create ${outdir}$name.best_bc_matches.txt";
	print OUT "seq_pair_count\tseq_bc1\tbc1_match\tbc1_match_dist\tseq_bc2\tbc2_match\tbc2_match_dist\tclosest_smpl\n";

	$|++; print "Comparing sequenced barcodes to expected..." unless $quiet;
	open INF, "<$inFile" or die "\n\tError: cannot open $inFile\n\n";
	while (<INF>) {
		my ($bc1) = /^([ACGTN]+)\t/;
		my ($bc2) = /^$bc1\t([ACGTN]+)\t/;
		my ($pair_ct) = /\t(\d+)$/;

		my $bc1Length = length $bc1;
		my $bc2Length = length $bc2;

		my %bc1distr;
		my %bc2distr;

		@bc1distr{@expBc1s} = map { abs } adistr($bc1, @expBc1s);
		my @sortedBc1distr = sort {$bc1distr{$a} <=> $bc1distr{$b}} @expBc1s;
		my $bestBc1match = $sortedBc1distr[0];
		my $bestBc1matchDist = $bc1distr{$sortedBc1distr[0]} * $bc1Length;
		if ($bestBc1matchDist >= $bc1Length) {$bestBc1match = "No_closest_match"}

		@bc2distr{@expBc2s} = map { abs } adistr($bc2, @expBc2s);
		my @sortedBc2distr = sort {$bc2distr{$a} <=> $bc2distr{$b}} @expBc2s;
		my $bestBc2match = $sortedBc2distr[0];
		my $bestBc2matchDist = $bc2distr{$sortedBc2distr[0]} * $bc2Length;
		if ($bestBc2matchDist >= $bc2Length) {$bestBc2match = "No_closest_match"}

		my $bestBcPair = "$bestBc1match\t$bestBc2match";
		my $bestMatchSmpl = "NA";
		unless ($bestBcPair =~ /No_closest_match/) {$bestMatchSmpl = $expBcSmpls{$bestBcPair}}
		unless ($bestMatchSmpl) {$bestMatchSmpl = "Not_a_valid_BC_pair"}

		print OUT "$pair_ct\t$bc1\t$bestBc1match\t$bestBc1matchDist\t$bc2\t$bestBc2match\t$bestBc2matchDist\t$bestMatchSmpl\n";
		$lineCount++;
		if ($lineCount % 1000 == 0) {
			$|++; print "$lineCount lines..." unless $quiet;
		}
	}
	close INF; close OUT;
	$|++; print "done\n" unless $quiet;
}

sub help_txt {
	print $usage;
}