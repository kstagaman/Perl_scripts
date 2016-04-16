#!/usr/bin/perl
# primes.pl
use strict; use warnings;

my $n = 0;
while (1) {
	$n++;
	redo if $n < 100;
	last if $n > 200; #breaks out of while loop
	
	my $prime = 1; #assumed true
	for (my $i = 2; $i < $n; $i++) {
		if ($n % $i == 0) {
			$prime = 0; #now known to be false
			last; #breaks out of for loop
		}
	}
	
	print "$n\n" if $prime;
}