#!/usr/bin/perl
# rename_paired_seqs.pl
use strict; use warnings;

# use this script to replaces the barcode in the fasta header for each sequence with the sample name and remove the primers from each read.  Run this script in the same directory as fasta files containing IgM forward, reverse and IgZ2 foward, reverse reads.

die "Usage: rename_paired_seqs.pl\n" unless @ARGV == 0;

my %barcodes = (		# hash containing barcodes (values) and labels (keys), change as needed.
	'TTCGG' => 'IgM_A_26',
	'ACAGG' => 'IgM_A_27',
	'ATCCC' => 'IgM_A_28',
	'CCCGA' => 'IgM_B_26',
	'CTATT' => 'IgM_B_27',
	'GATGC' => 'IgM_B_28',
	'GGTTC' => 'IgM_C_26',
	'TCCTG' => 'IgM_C_27',
	'TTCTC' => 'IgM_C_28',
	'ACCGC' => 'IgM_D_26',
	'ATGAG' => 'IgM_D_27',
	'CCGCG' => 'IgM_D_28',
	'CTCTA' => 'IgZ2_A_26',
	'GCATT' => 'IgZ2_A_27',
	'GTACT' => 'IgZ2_A_28',
	'TCGTT' => 'IgZ2_B_26',
	'TTGAA' => 'IgZ2_B_27',
	'ACGTA' => 'IgZ2_B_28',
	'ATGCT' => 'IgZ2_C_26',
	'CCGGT' => 'IgZ2_C_27',
	'CTGTC' => 'IgZ2_C_28',
	'GCCAT' => 'IgZ2_D_26',
	'GTAGC' => 'IgZ2_D_27',
	'TCTGA' => 'IgZ2_D_28',
	'TTGCG' => 'IgM_A_29',
	'ACTAA' => 'IgM_A_30',
	'ATTAT' => 'IgM_A_31',
	'CCTGC' => 'IgM_B_29',
	'CTTCG' => 'IgM_B_30',
	'GCCCG' => 'IgM_B_31',
	'GTGCC' => 'IgM_C_29',
	'TCTTC' => 'IgM_C_30',
	'TTGGT' => 'IgM_C_31',
	'ACTCC' => 'IgM_D_29',
	'ATTCA' => 'IgM_D_30',
	'CGAAC' => 'IgM_D_31',
	'GAAAC' => 'IgZ2_A_29',
	'GCCTA' => 'IgZ2_A_30',
	'GTGGA' => 'IgZ2_A_31',
	'TGACA' => 'IgZ2_B_29',
	'TTTAG' => 'IgZ2_B_30',
	'AACCC' => 'IgZ2_B_31',
	'AAGGG' => 'IgZ2_C_29',
	'CAGTC' => 'IgZ2_C_30',
	'CGCGC' => 'IgZ2_C_31',
	'CTTCC' => 'IgZ2_D_29',
	'GCCGG' => 'IgZ2_D_30',
	'GTGTG' => 'IgZ2_D_31',
	'CCTTG' => 'IgM_A_26.1',
	'CACAG' => 'IgM_C_26.1',
);


my @fwd_files = `ls *.fwd.fa`;
my @rev_files = `ls *.rev.fa`;
chomp @fwd_files; chomp @rev_files;
my $i = 1;
my $j = 1;

# fwd read stuff

foreach my $fwd_file (@fwd_files) {
	open IN, "<$fwd_file" or die "Error: cannot open $fwd_file\n";
	open OUT, ">renamed_$fwd_file" or die "Error: cannot creat renamed_$fwd_file\n";
	while (<IN>) {
		if ($_ =~ /^\>/) {
			my ($barcode) = $_ =~ /^\>([ACGT]{5})_/;
			print OUT "\>$i\:$barcodes{$barcode}\:\n";
			$_ = <IN>;
			my ($seq) = $_ =~ /([ACGTN]+)/;
			print OUT "$seq\n";
			$i++;
		}
	}
	close IN; close OUT;
}

# rev read stuff

foreach my $rev_file (@rev_files) {
	open IN, "<$rev_file" or die "Error: cannot open $rev_file\n";
	open OUT, ">renamed_$rev_file" or die "Error: cannot creat renamed_$rev_file\n";
	while (<IN>) {
		if ($_ =~ /^\>/) {
			my ($barcode) = $_ =~ /^\>([ACGT]{5})_/;
			print OUT "\>$j\:$barcodes{$barcode}\:\n";
			$_ = <IN>;
			my ($seq) = $_ =~ /([ACGTN]+)/;
			if ($rev_file =~ /igm/) { 
				my ($noprimer) = substr($seq, 0, -20);
				print OUT "$noprimer\n";
			}
			else {
				my ($noprimer) = substr($seq, 0, -25);
				print OUT "$noprimer\n";
			}
			$j++;
		}
	}
	close IN; close OUT;
}