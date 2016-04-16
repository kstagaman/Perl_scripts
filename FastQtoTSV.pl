#!/usr/bin/perl
# FastQtoTSV.pl by Keaton Stagaman
use strict; use warnings;

open(FASTQ, "<$ARGV[0]") or die "error reading $ARGV[0]";	# input here is any fastq file
open(TSV, ">$ARGV[0].tsv") or die "error creating $ARGV[0].tsv";

print TSV "LANE\tTILE_NUM\tX_COORD\tY_COORD\tPAIR_NUM\tSEQUENCE\tQUALITY_SCORE\n"; # set headers for TSV file

while (my $line = <FASTQ>) {

	if ($line =~ /^\@HWI-ST0747/) {	# extract lane & tile numbers, x- & y-coordinates, and which end of the pair each seq is
		my ($lane, $tile_no, $x_coord, $y_coord, $pair_no) = $line =~ /XX\:(\d)\:(\d{4})\:(\d+)\:(\d+)\s(\d)\:[YN]/;
		$line = <FASTQ>;
		my ($seq) = $line =~ /([ACGTN]{153})/; # extract sequence
		$line = <FASTQ>;
		$line = <FASTQ>;
		my ($qual) = $line =~/(.{153})/;	# extract quality scores
		print TSV "$lane\t$tile_no\t$x_coord\t$y_coord\t$pair_no\t$seq\t$qual\n";
	}
}

close FASTQ;
close TSV;
