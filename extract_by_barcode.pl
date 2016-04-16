#!/usr/bin/perl
# extract_by_barcode.pl by Keaton Stagaman
use strict; use warnings;

my %barcodes = (		# hash containing barcodes (values) and labels (keys), change as needed.
	'07H' => 'TTCGG',
	'08A' => 'ACAGG',
	'08B' => 'ATCCC',
	'08C' => 'CCCGA',
	'08D' => 'CTATT',
	'08E' => 'GATGC',
	'08F' => 'GGTTC',
	'08G' => 'TCCTG',
	'08H' => 'TTCTC',
	'09A' => 'ACCGC',
	'09B' => 'ATGAG',
	'09C' => 'CCGCG',
	'09D' => 'CTCTA',
	'09E' => 'GCATT',
	'09F' => 'GTACT',
	'09G' => 'TCGTT',
	'09H' => 'TTGAA',
	'10A' => 'ACGTA',
	'10B' => 'ATGCT',
	'10C' => 'CCGGT',
	'10D' => 'CTGTC',
	'10E' => 'GCCAT',
	'10F' => 'GTAGC',
	'10G' => 'TCTGA',
	'10H' => 'TTGCG',
	'11A' => 'ACTAA',
	'11B' => 'ATTAT',
	'11C' => 'CCTGC',
	'11D' => 'CTTCG',
	'11E' => 'GCCCG',
	'11F' => 'GTGCC',
	'11G' => 'TCTTC',
	'11H' => 'TTGGT',
	'12A' => 'ACTCC',
	'12B' => 'ATTCA',
	'12C' => 'CGAAC',
	'12D' => 'GAAAC',
	'12E' => 'GCCTA',
	'12F' => 'GTGGA',
	'12G' => 'TGACA',
	'12H' => 'TTTAG',
	'1-PE' => 'AACCC',
	'2-PE' => 'AAGGG',
	'3-PE' => 'CAGTC',
	'4-PE' => 'CGCGC',
	'5-PE' => 'CTTCC',
	'6-PE' => 'GCCGG',
	'7-PE' => 'GTGTG',
	'8-PE' => 'CCTTG',
	'9-PE' => 'CACAG',
);


foreach my $key (keys %barcodes) { 								
	open (TSV, "<$ARGV[0]") or die "error reading $ARGV[0]";	# reopens TSV file for each barcode (bc).  Probably not the
	my $oneline = <TSV>;										# most efficient way to do this.
	$oneline = <TSV>;
	my ($read_num) = $oneline =~ /\t(\d)\t[ACGTN]/;
	
	open(EXT, ">$barcodes{$key}read$read_num.tsv");		# create an output file for all seqs with same bc.  Problem here
														# is that a file is created for all barcodes, even if it's 
	while (my $line = <TSV>) {							# empty.

		if ($line =~ /\t$barcodes{$key}/) {			# if a line matches the bc, it's put in the file
			my ($seq) = $line;
			print EXT "$seq";
		}
	}
	close TSV;
	close EXT;
}