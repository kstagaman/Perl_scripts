#!/usr/bin/perl
# compare_segs_2files.pl
use strict; use warnings;

# Use this script to see if the Jseg assignment from classify.seqs (mothur) is the same
# between two .taxonomy files generated using differing parameters.


die "Usage: compare_jseg_2files.pl <taxonomy file 1> <taxonomy file 2>\n" unless @ARGV == 2;

open IN1, "<$ARGV[0]" or die "Error: cannot open $ARGV[0]\n";
my ($file_name) = $ARGV[0] =~ /^(\S+)\.ksize/;
my ($parameters1) = $ARGV[0] =~ /(ksize\d+)/;
my ($seg_type) = $ARGV[0] =~ /\.([VDJ][mz]*)\.taxonomy/;

open IN2, "<$ARGV[1]" or die "Error: cannot open $ARGV[1]\n";
my ($parameters2) = $ARGV[1] =~ /(ksize\d+)/;

open OUT, ">$file_name.$parameters1\_$parameters2\_consensus.$seg_type.taxonomy" or die "Error: cannot create $file_name.$parameters1\_$parameters2\_consensus.$seg_type.taxonomy\n";

my @assignment1s;
my @assignment2s;
my $i = 0;

while (<IN1>) {
	my ($id) = $_ =~ /^(\S+)/;
	my ($seg) = $_ =~ /([VDJ][mz]*\d+)\(/;
	$assignment1s[$i] = {id => $id, seg => $seg};
	$i++;
}

while (<IN2>) {
	my ($seg) = $_ =~ /([VDJ][mz]*\d+)\(/;
	push @assignment2s, $seg;
}

close IN1; close IN2;

my $k = 0;

for (my $j = 0; $j < @assignment1s; $j++) {
	if ($assignment1s[$j]->{seg} eq $assignment2s[$j]) {
		print OUT "$assignment1s[$j]->{id}\t$assignment2s[$j]\;\n";
		$k++;
	}
}

close OUT;

my $consensus = $k / $i;

printf "%s %.3f consensus\n", $file_name, $consensus;

