#!/usr/bin/perl
# paired_count.pl
use strict; use warnings;

my @paired_files = `ls *.fa_1`;
my @unpaired_files = `ls *.fa`;
chomp @paired_files; chomp @unpaired_files;
my $paired_reads_count = 0;
my $unpaired_reads_count = 0;
my $total_paired_files = @paired_files;
my $total_unpaired_files = @unpaired_files;
my $i = 0;
my $j = 0;

foreach my $paired_file (@paired_files) {
	my ($paired_file_lines) = `wc -l $paired_file`;
	my ($paired_file_line_count) = $paired_file_lines =~ /(\d+)\ssample/;
	my $paired_file_read_count = $paired_file_line_count / 2;
	$paired_reads_count += $paired_file_read_count;
	$i++;
	print "$i of $total_paired_files paired files completed\n";
}

foreach my $unpaired_file (@unpaired_files) {
	my ($unpaired_file_lines) = `wc -l $unpaired_file`;
	my ($unpaired_file_line_count) = $unpaired_file_lines =~ /(\d+)\ssample/;
	my $unpaired_file_read_count = $unpaired_file_line_count / 2;
	$unpaired_reads_count += $unpaired_file_read_count;
	$j++;
	print "$j of $total_unpaired_files unpaired files completed\n";
}

print "\nTotal paired reads: $paired_reads_count\n";
print "Total unpaired reads: $unpaired_reads_count\n\n";