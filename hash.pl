#!/usr/bin/perl
# hash.pl
use strict; use warnings;

my %genetic_code = (
	ATG => 'Met',
	AAA => 'Lys',
	CCA => 'Pro',
);
print "$genetic_code{'ATG'}\n";
foreach my $key (sort keys %genetic_code) {
	print "$key $genetic_code{$key}\n";
}
my @keys = keys(%genetic_code);
my @vals = values(%genetic_code);
print "keys: @keys\n";
print "values: @vals\n";
$genetic_code{CCG} = 'Pro';
$genetic_code{AAA} = 'Lysine';
if (exists $genetic_code{AAA}) {print "AAA codon has a value\n"}
else {print "No value set for AAA codon\n"}
delete $genetic_code{AAA};
if (exists $genetic_code{AAA}) {print "AAA codon has a value\n"}
else {print "No value set for AAA codon\n"}