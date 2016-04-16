#!/usr/bin/perl
# gc1.pl
use strict; use warnings;

die "usage: <sequence> <threshold>\n" unless @ARGV == 2;
my @seqthresh = @ARGV;
my $seq = gc(@seqthresh);  #adding this $seq variable is very important
print "$seq\n";

sub gc {
	my ($seq) = $seqthresh[0];
	my ($threshold) = $seqthresh[1];

	$seq = uc($seq); # convert to upper case to be sure
	my $g = $seq =~ tr/G/G/;
	my $c = $seq =~ tr/C/C/;
	my $gc = ($g + $c) / length($seq);
	print "GC% = $gc\n";
	
	if ($gc > $threshold) {
		return ("High GC");
	} else {
		return("Low GC");
	}
}
