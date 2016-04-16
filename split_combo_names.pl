#!/usr/bin/perl
# split_combo_names.pl
use strict; use warnings;


open IN, "<$ARGV[0]" or die "can't open $ARGV[0]";
open OUT, ">$ARGV[0].split" or die "can't create $ARGV[0].split";

$_ = <IN>;
print OUT "\"sample\" \"vseg\" \"jseg\" \"abundance\"\n";

while (<IN>) {
	my @halves = split(/\./, $_);
	chomp @halves;
	my ($front_half) = join('', split(/V/, $halves[0]));
	my ($back_half) = $halves[1] =~ /^Jm(.+)/;
	print OUT "$front_half\" ";
	print OUT "\"$back_half\n";
}
close IN; close OUT;
