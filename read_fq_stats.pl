#!/usr/bin/perl
# read_fq_stats.pl
use strict; use warnings;

my @files = `ls *.fq *.fq_[12]`;
chomp @files;
my @lengths; # array containing the length of each read from all files
my $file_count = @files;

# get the lengths of all the reads in each file and add them to the lengths array
for (my $i = 0; $i < @files; $i++) {
	my ($file) = $files[$i];
	open(IN, "<$file") or die "Error: can't open one or more fasta files\n";
	
	while (<IN>) {
		
		if ($_ =~ /^\@[ACGT]{5}\_/) {
		    my $line = <IN>;
            my ($seq) = $line;
			my $length = length($seq);
			push(@lengths, $length);
		}
	}
	my $curr_file = $i + 1;
	print "$curr_file of $file_count total files completed\n";
}

my $total = 0;

foreach my $length (@lengths) {
	$total += $length;
}

# stats
# count
my $count = @lengths;


# mean
my $avg_read = $total / $count;

# numbers of paired and unpaired reads.
my @paired_files = `ls *.fq_1`;
my @unpaired_files = `ls *.fq`;
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
	my $paired_file_read_count = $paired_file_line_count / 4;
	$paired_reads_count += $paired_file_read_count;
	$i++;
	print "$i of $total_paired_files paired files completed\n";
}

foreach my $unpaired_file (@unpaired_files) {
	my ($unpaired_file_lines) = `wc -l $unpaired_file`;
	my ($unpaired_file_line_count) = $unpaired_file_lines =~ /(\d+)\ssample/;
	my $unpaired_file_read_count = $unpaired_file_line_count / 4;
	$unpaired_reads_count += $unpaired_file_read_count;
	$j++;
	print "$j of $total_unpaired_files unpaired files completed\n";
}

# standard deviation

my $var_sum = 0;
for (my $i = 0; $i < @lengths; $i++) {
	$var_sum += ($avg_read - $lengths[$i]) ** 2;
}
my $var = $var_sum / ($count - 1);
my $sd = sqrt($var);

print "\nTotal \# reads: $count\n";
printf "Average read length: %.2f\n", $avg_read;

# median
my @sorted_lengths = sort {$a <=> $b} @lengths;

if ($count % 2 == 0) {
	my $offset1 = ($count / 2) - 1;
	my $offset2 = ($count / 2);
	my $med_val1 = splice(@sorted_lengths, $offset1, 1);
	my $med_val2 = splice(@sorted_lengths, $offset2, 1);
	my $even_med = ($med_val1 + $med_val2) / 2;
	print "Median read length: $even_med\n";
} else {
	my $offset3 = ($count / 2);
	my $odd_med = splice(@sorted_lengths, $offset3, 1);
	print "Median read length: $odd_med\n";
}

printf "Standard deviation: %.2f\n", $sd;
print "Total paired reads: $paired_reads_count\n";
print "Total unpaired reads: $unpaired_reads_count\n\n";
