#!/usr/bin/perl
# isPrime.pl
use strict; use warnings;

my $usage = "\n\tisPrime.pl <integer>\n\n";

die $usage unless @ARGV==1;
die $usage unless $ARGV[0] =~ /^\d+$/;

TEST: for (my $i=2; $i<$ARGV[0]-1; $i++) {
	if ($ARGV[0] % $i == 0){
		print "$ARGV[0] is not prime\n";
		last TEST;
	}
	elsif ($i == $ARGV[0]-1) { ###
		print "$ARGV[0] is prime\n";
	}
}

