#!/usr/bin/perl
# hydrophobicity.pl
use strict; use warnings;
use Library;

die "usage: hydrophobicity.pl <sequence type (DNA or AA)> <sequence> <window (in AAs)>\n" unless @ARGV == 3;

if ($ARGV[0] =~ /DNA/i) {
	my ($seq) = $ARGV[1];
	my @translations = Library::translate($seq);
	my ($longestorf) = Library::longestorf(@translations);
	print "\nAA sequence: $longestorf\n\n";
	my @hydropathies = Library::KDhydropathy($longestorf);
	#print "@hydropathies\n";
} 

elsif ($ARGV[0] =~ /AA/i) {
	my ($seq) = $ARGV[1];
	$seq = uc($seq);
	print "\nAA sequence: $seq\n\n";
	my @hydropathies = Library::KDhydropathy($seq);
}

else {print "\nSequence type must be DNA or AA\n\n";}