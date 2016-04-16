#!/usr/bin/perl
# loop.pl
use strict; use warnings;

for (my $i = 0; $i < 10; $i++) { # $i++ is the same as $i = $i + 1
	print "$i\n";
}
for (my $i = 50; $i >= 45; $i--) {
	print "$i\n";
}
for (my $i = 0; $i < 100; $i += 10) { # $i += 10 is the same as $i = $i + 10
	print "$i\n";
}