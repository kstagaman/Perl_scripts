#!/usr/bin/perl
# transliterate.pl
use strict; use warnings;

my $text = "these are letters: abcdef, and these are numbers, 123456";
print "$text\n";

$text =~ tr/a/b/;
print "$text\n";

$text =~ tr/bs/at/;
print "$text\n";

$text =~ tr/123/321/;
print "$text\n";

$text =~ tr/abc/ABC/;
print "$text\n";

$text =~ tr/ABC/X/;
print "$text\n";

$text =~ tr/d/DE/;
print "$text\n";

$text =~ tr [abcdefgh]
			[hgfedcba];
print "$text\n";

my $sequence = "AACTAGCGGAATTCCGACCGT";
my $g_count = ($sequence =~ tr/G/G/);
print "The letter G occurs $g_count times in $sequence\n";

$sequence =~ tr/A-Z/a-z/;
print "$sequence\n";