#!/usr/bin/perl
# accession_numbers.pl
use strict; use warnings;

die "Usage: accession_numbers.pl <.parsed file>\n" unless @ARGV == 1;

open IN, "<$ARGV[0]" or die "Error: cannot open $ARGV[1]\n";

my ($tag) = $ARGV[0] =~ /(.+).parsed$/;

my %accessions;

while (<IN>) {
	if ($_ !~ /^\>/ and $_ !~ /^\s/) {
		my ($accession) = $_ =~ /^(\w+\.*\d*)\s/;
		if ($accession) {
			if (exists $accessions{$accession}) {$accessions{$accession}++}
			else								{$accessions{$accession} = 1}
		}
	}
}

close IN;

open AnA, ">$tag.acc_abund" or die "Error: cannot create $tag.acc_abund\n";
open AO, ">$tag.accessions" or die "Error: cannot create $tag.accessions\n";

my @accessions = keys %accessions;

foreach my $accession (@accessions) {
	print AnA "$accession\t$accessions{$accession}\n";
	print AO "$accession\n";
}

close AnA; close AO;

			