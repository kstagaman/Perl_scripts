#!/usr/bin/perl
# get_blast_stats.pl
use strict; use warnings;

# Use this script after running blast_output.pl on a bunch of files to create a .csv file to analyze the data in R.
# Run in directory containing *.blastout.igs files.
die "Don't use this!\n";
die "Usage: get_blast_stats.pl\n" unless @ARGV == 0;

my @ig_files = `ls *blastout.igs`;
chomp @ig_files;

open OUT, ">blastout_data.csv" or die "Error: cannot create blastout_data.csv\n";
print OUT "sample,ig,tank,fish,seq.type,primer.match,sample.num,ig.seqs,danio.seqs,no.hits,";

foreach my $ig_file (@ig_files) {
	my ($sample) = $ig_file =~ /(\S+)\.blastout\.igs/;
	my ($ig) = $sample =~ /^([mz])/;
	my ($tank) = $sample =~ /^[mz]([abcd])/;
	my ($fish) = $sample =~ /^[mz][abcd](\d{2})/;
	my ($seq_type) = $sample =~ /\.(\w+)$/;
	my ($primer_match) = "NA";
	if ($sample !~/[mz][abcd][23][678901]\.[gu]/) {
		($primer_match) = $sample =~ /[mz][abcd][23][678901]\.(.+)\.[gu]/;
	}
	open IG, "<$ig_file" or die "Error: cannot open $ig_file\n";
	$_ = <IG>;
	my ($total_blasted) = $_ =~ /: (\d+)$/;
	$_ = <IG>;
	my ($ig_blasted) = $_ =~ /: (\d+) \(/;
	$_ = <IG>;
	my ($danio_blasted) = $_ =~ /: (\d+) \(/;
	$_ = <IG>;
	my ($no_hits) = $_ =~ /: (\d+) \(/;

	print OUT "$sample,$ig,$tank,$fish,$seq_type,$primer_match,$total_blasted,$ig_blasted,$danio_blasted,$no_hits,";
	printf OUT "%d,%d,%.3f,%d,%d\n", $min_len,$max_len,$mean_len,$median_len,$mode_len;
	close IG;
}

close OUT;