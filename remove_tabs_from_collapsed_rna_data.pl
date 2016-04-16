#!/usr/bin/perl
# remove_tabs_from_collapsed_rna_data.pl
use strict; use warnings;

# use this script to remove the tabs between identifiers in Tom's collapsed RNA data

die "Usage: remove_tabs_from_collapsed_rna_data.pl <fasta file>\n" unless @ARGV == 1;

open IN, "<$ARGV[0]" or die "Error: cannot open $ARGV[0]\n";
my ($file_name) = $ARGV[0] =~ /(\w+)\.fas*t*a*$/;

open OUT, ">$file_name.fa" or die "Error: cannot create $file_name.fa\n";

while (<IN>) {
	if ($_ =~ /^\>/) {
		my ($id) = $_ =~ /^(\>\w+)/;
		my ($n)  = $_ =~ /\s(\d+\.*\d*)\s/;
		my ($bp) = $_ =~ /(\d+bp)$/;
		$_ = <IN>;
		my ($raw_seq) = $_;
		chomp $raw_seq;
		my ($seq) = revcomp($raw_seq);
		print OUT "$id:$n:$bp\n$seq\n";
	}
}


sub revcomp {
	my ($seq) = @_;
	$seq = uc($seq);
	my $rev = reverse($seq);
	$rev =~ tr/ACGTURYKMBVDH/TGCAAYRMKVBHD/; # makes complement
	return($rev)
}