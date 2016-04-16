#!/usr/bin/perl
# matching.pl
use strict; use warnings;

my $sequence = "AACTAGCGGAATTCCGACCGT";
if ($sequence =~ m/GAATTC/) {print "EcoRI site found\n"}
else                        {print "no EcoRI site found\n"}
$sequence =~ s/GAATTC/gaattc/;
print "$sequence\n";
$sequence =~ s/A/adenine/;
print "$sequence\n";
$sequence =~ s/C//g;
print "$sequence\n";

my $protein = "MVGGKKKTKICDKVSHEEDRISQLPEPLISEILFHLSTKDLWQSVPGLD";
print "Protein contains proline\n" if ($protein =~ m/p/i);

my $input = "ACNGTARGCCTCACACQ";
die "non-DNA character in input\n" if ($input =~ m/[efijlopqxz]/i);
print "We never get here\n";