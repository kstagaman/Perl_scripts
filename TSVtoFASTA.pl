#!/usr/bin/perl
# TSVtoFASTA.pl
use strict; use warnings;

die "Usage: TSVtoFASTA.pl <.tsv file>\n" unless @ARGV == 1;

my ($tag) = $ARGV[0] =~ /(.+)\.tsv/;

open(TSV, "<$ARGV[0]") or die "Error: cannot open .tsv file";
open(FA, ">$tag.fa") or die "Error: cannot creat .fa file";

while (my $line = <TSV>) {
	my ($id) = $line =~ /^(\>\w+)\t/;
	my ($aaseq) = $line =~ /\t(\w+)/;
	print FA "$id\n$aaseq\n";
}

close TSV; close FA;