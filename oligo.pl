#!/usr/bin/perl
# oligo.pl
use strict; use warnings;

die "usage: oligo.pl <file of oligos>\n" unless @ARGV == 1;

my (%sequences, %tm); # declare hashes

# process file line by line
while (<>) {
	chomp; # removes \n from each line
	
	# store sequence
	my ($name, $seq) = split("\t", $_);
	$sequences{$name} = $seq;
	
	# calculate and store Tm
	my $A = $seq =~ tr/A/A/;
	my $C = $seq =~ tr/C/C/;
	my $G = $seq =~ tr/G/G/;
	my $T = $seq =~ tr/T/T/;
	my $tm = 2 * ($A + $T) + 4 * ($C + $G); # simple Tm formula
	$tm{$name} = $tm;
}

# report oligos sorted by Tm
foreach my $name (sort {$tm{$a} <=> $tm{$b}} keys %tm) {
	print "$name\t$tm{$name}\t$sequences{$name}\n";
}