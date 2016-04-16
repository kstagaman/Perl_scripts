#!/usr/bin/perl
# system.pl
use strict; use warnings;

my @files = `ls`;
print "@files\n";
my $file_count = `ls | wc`;
print "$file_count\n";
system("ls > foo") == 0 or die "Command failed\n";
open(IN, "<foo") or die "Can't open foo\n";
my @files = <IN>; # reads the entire file into @files
close IN;
foreach my $file (@files) {print "$file\n"}
# file handle 'IN' will now receive output from the 'ls' command
open (IN, "ls |") or die;
while (my $line = <IN>) {
	print "file: ", $line;
}
# the file handle OUT will now connect to the Unix wc command
open(OUT, "| wc") or die;
print OUT "this sentence has 1 line, 10 words, and 51 letters\n";
close OUT;