#!/usr/bin/perl
# fiddle_ics.pl
use strict; use warnings;

die "\n\tUsage: fiddle_ics.pl <ICS file>\n\n" unless @ARGV == 1;

open IN, "<$ARGV[0]" or die "\n\tError: cannot open $ARGV[0]\n\n";

my ($name) = $ARGV[0] =~ /(.+)\.ics$/;
open OUT, ">$name.fiddled.ics" or die "\n\tError: cannot create $name.fiddled.ics\n\n";

while (<IN>) {
	if ($_ =~ /^SEQUENCE:/) {
		my ($num) = /^SEQUENCE:(\d+)/;
		my $new_num = $num + 2;
		print OUT "SEQUENCE:$new_num\n";
	} else {
		print OUT $_;
	}
}
close IN; close OUT;