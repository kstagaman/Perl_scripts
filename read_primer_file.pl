#!/usr/bin/perl
# read_primer_file.pl
use strict; use warnings;

open PRIMERS, "<$ARGV[0]" or die "Error: Cannot open primer file\n";
my ($fwd_primer) = ();
my ($rev_primer) = ();

while (my $line = <PRIMERS>) {
	if ($line =~ m/^\>f/i) {
		$line = <PRIMERS>;
		($fwd_primer) = $line =~ m/(\w+)/;
	}
	if ($line =~ m/^\>r/i) {
		$line = <PRIMERS>;
		($rev_primer) = $line =~ m/(\w+)/;
	}
}

print "The forward primer sequence is $fwd_primer\n";
print "The reverse primer sequence is $rev_primer\n";