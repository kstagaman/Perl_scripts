#!/usr/bin/perl
# shuffle1.pl
use strict; use warnings;

die "usage: testproj.pl <dna sequence>\n" unless @ARGV == 1;
my ($sequence) = @ARGV;
my @seq = split("", $sequence);
my $seqlength = @seq;

my $iters = 10; #set number of iterations here

for (my $i = 0; $i < $iters; $i++) {
	my $pos1 = int rand $seqlength; #generate positions where subs will occur
	my $pos2 = int rand $seqlength;
	
	my $val1 = splice(@seq, $pos1, 1); #get letter from positions
	splice(@seq, $pos1, 0, $val1);	   #put letter back to maintain seq
	my $val2 = splice(@seq, $pos2, 1);
	splice(@seq, $pos2, 0, $val2);
	
	splice(@seq, $pos2, 1, $val1); #put 1st letter into 2nd pos
	splice(@seq, $pos1, 1, $val2); #put 2nd letter into 1st pos
}
print "@seq\n";