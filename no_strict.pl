#!/usr/bin/perl
# no_strict.pl
use warnings;

my $seq = "atg att gaa cca tga";
$codon = count_codons($seq);
print "$seq contains $codons codons\n";

sub count_codons {
	$seq = shift;
	$seq = uc($seq);
	$seq =~ s/\s+//g;
	$codons = length($seq) / 3;
	return($codons);
}