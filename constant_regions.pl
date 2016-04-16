#!/usr/bin/perl
# constant_regions.pl
use strict; use warnings;

my @IgMfiles = `ls sample_IgM*`;
my @IgZ2files = `ls sample_IgZ2*`;
chomp (@IgMfiles, @IgZ2files);

my $IgMC_count;
my $IgZ2C_count;
my $IgM_lines;
my $IgZ2_lines;

foreach my $IgMfile (@IgMfiles) {
	open (MSEQS, "<$IgMfile") or die "Error: cannot open one or more IgM fasta files";

	while (my $line = <MSEQS>) {
		$IgM_lines++;

		if ($line =~ /CAACCATCTGCGCCCCAGTCAGTCTTCGGT/) {
			$IgMC_count++;
		}
		elsif ($line =~ /ACCGAAGACTGACTGGGGCGCAGATGGTTG/) {
			$IgMC_count++;
		}
	}
	close MSEQS;
}

my $IgMseq_count = $IgM_lines / 2;
my $IgM_percent = $IgMC_count / $IgMseq_count * 100;

foreach my $IgZ2file (@IgZ2files) {
	open (Z2SEQS, "<$IgZ2file") or die "Error: cannot open one or more IgZ2 fasta files";

	while (my $line = <Z2SEQS>) {
		$IgZ2_lines++;

		if ($line =~ /GAAACTCTCACAGCACCAGTTGTGTTCAAA/) {
			$IgZ2C_count++;
		}
		elsif ($line =~ /TTTGAACACAACTGGTGCTGTGAGAGTTTC/) {
			$IgZ2C_count++;
		}
	}
	close Z2SEQS;
}

my $IgZ2seq_count = $IgZ2_lines / 2;
my $IgZ2_percent = $IgZ2C_count / $IgZ2seq_count * 100;

print "\n$IgMC_count out of $IgMseq_count sequences contain the canonical IgM constant region\nthis is $IgM_percent\% of the total sequences\n";

print "\n$IgZ2C_count out of $IgZ2seq_count sequences contain the canonical IgZ2 constant region\nthis is $IgZ2_percent\% of the total sequences\n\n";