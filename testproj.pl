#!/usr/bin/perl
# testproj.pl Keaton
use strict; use warnings;

die "usage: testproj.pl <dna sequence>\n" unless @ARGV == 1;
my ($seq) = @ARGV;

print "\n\n";

#calculate and print sequence length
my $seqlth = length($seq);
print "Sequence length: $seqlth bp\n\n";

#tally A, C, G, and T nucleotides
my $a_count = ($seq =~ tr/aA/aA/);
print "# A: $a_count\n";

my $c_count = ($seq =~ tr/cC/cC/);
print "# C: $c_count\n";

my $g_count = ($seq =~ tr/gG/gG/);
print "# G: $g_count\n";

my $t_count = ($seq =~ tr/tT/tT/);
print "# T: $t_count\n\n";

#fraction of nucleotides in sequence
my $a_percent = ($a_count / $seqlth) * 100;
print "% A: "; printf("%.2f", $a_percent); print "%\n";

my $c_percent = ($c_count / $seqlth) * 100;
print "% C: "; printf("%.2f", $c_percent); print "%\n";

my $g_percent = ($g_count / $seqlth) * 100;
print "% G: "; printf("%.2f", $g_percent); print "%\n";

my $t_percent = ($t_count / $seqlth) * 100;
print "% T: "; printf("%.2f", $t_percent); print "%\n\n";

#GC fraction
my $gc_frac = ($g_count + $c_count) / $seqlth * 100;
print "% GC: "; printf("%.2f", $gc_frac); print "%\n\n";