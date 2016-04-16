#!/usr/bin/perl
# process_seqs_.pl
use strict; use warnings;

die "Usage: process_seqs_.pl <num> <file>\n" unless @ARGV == 2;

my $filename = $ARGV[1];
print "File: $filename\n";

for (my $i = 0; $i < $ARGV[0]; $i++) {
	if ($i % 10000 == 0) {
		print "$i seqs processed\n";
		system("sleep 10s");
	}
}
		