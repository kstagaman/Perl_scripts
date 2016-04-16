#!/usr/bin/perl
# illumina_process.pl by Keaton Stagaman
use strict; use warnings;
use Library;

die "usage: illumina_process.pl <.fasta file>" unless @ARGV == 1;
my $fasta = $ARGV[0];
my $tsv = Library::fastq_to_tsv($fasta);
