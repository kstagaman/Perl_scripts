#!/usr/bin/perl
# gc.pl
use strict; use warnings;

while (my $seq = <>) {
	chomp($seq);
	gc($seq);
	print "$seq\n";
}

sub gc {
	
	my ($seq) = @_;
	$seq = uc($seq); # convert to upper case to be sure
	my $g = $seq =~ tr/G/G/;
	my $c = $seq =~ tr/C/C/;
	my $gc = ($g + $c) / length($seq);
	print "GC% = $gc\n";
}
