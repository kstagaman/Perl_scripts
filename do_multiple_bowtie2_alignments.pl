#!/usr/bin/perl
# do_multiple_bowtie2_alignments.pl
use strict; use warnings;

# use this script to perform bowtie2-align on multiple files

die "Usage: do_multiple_bowtie2_alignments.pl <mate1 files regex> <mate2 files regex>\n" unless @ARGV == 2;

my @file1s = `ls *$ARGV[0]*`;
my @file2s = `ls *$ARGV[1]*`;
chomp (@file1s, @file2s);

for (my $i = 0; $i < @file1s; $i++) {
	my ($output_name) = $file1s[$i] =~ /(\S+)\.fwd\.fa$/;
	system("bowtie2-align -f -I 350 -X 550  -x ~/Zf_bowtie2_chr3_ref -1 $file1s[$i] -2 $file2s[$i] -S $output_name.bowtie2.out");
}