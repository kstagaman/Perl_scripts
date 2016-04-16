#!/usr/bin/perl
# revcomp_fa.pl
use strict; use warnings;

die "Usage: revcomp_fa.pl <fasta file>\n" unless @ARGV == 1;

open IN, "<$ARGV[0]" or die "Error: cannot open fasta file";
open OUT, ">revcomp_$ARGV[0]";

while (<IN>) {
	if ($_ =~ /^\>/) {
		my ($id) = $_;
		print OUT "$id";
		$_ = <IN>;
		my ($seq) = $_ =~ /(\w+)/;
		my $revcomp = reverse $seq;
		$revcomp =~ tr/ACGTURYKMBVDH/TGCAAYRMKVBHD/;
		print OUT "$revcomp\n";
	}
}

close IN; close OUT;


		