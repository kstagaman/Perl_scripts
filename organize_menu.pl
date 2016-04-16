#!/usr/bin/perl
# organize_menu.pl
use strict; use warnings;

die "Usage: organize_menu.pl <txt file>\n" unless @ARGV == 1;

open IN, "<$ARGV[0]" or die "Error: cannot open $ARGV[0]\n";
my ($filename) = $ARGV[0] =~ /(\w+)_copied.txt$/;
open OUT, ">$filename.txt" or die "Error: cannot create $filename.txt\n";

while (<IN>) {
	if ($_ =~ /^\>/) {
		my ($course) = $_ =~ /\>(.+)\n$/;
		print OUT "$course\n";
		$_ = <IN>;
		until ($_ =~ /^\@/) {
			my ($item) = $_ =~ /(\D+)\s+\d*/;
			my ($cost) = $_ =~ /(\d+\.*\d*\-*\d*\.*\d*)/;
			if (!$cost) {
				my ($cost_min) = $course =~ /(\d+\.*\d*)\sto\s\d/;
				my ($cost_max) = $course =~ /\d+\.*\d*\sto\s(\d+\.*\d*)/;
				if (!$cost_min or !$cost_max) {
					$cost_min = 0;
					$cost_max = 0;
				}
				$cost = ($cost_min + $cost_max) / 2;

			}
			print OUT "\t$item\t$cost\n";
			$_ = <IN>;
		}
		print OUT "@\n";
	}
}

close IN; close OUT;