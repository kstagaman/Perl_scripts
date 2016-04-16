#!/usr/bin/perl
# stringarry.pl
use strict; use warnings;

my @gene_names = qw(unc-10 cyc-1 act-1 let-7 dyf-2);
my $joined_string = join(", ", @gene_names);
print "$joined_string\n";
my $dna = "aaaaGAATTCttttttGAATTCggggggg";
my $EcoRI = "GAATTC";
my @digest = split($EcoRI, $dna);
print "@digest\n";
my @dna = split("", $dna);
print "@dna\n";