#!/usr/bin/perl
# truncate_fastq.pl
use strict; use warnings;

die "Usage: truncate_fastq.pl <fastq file> <desired length>\n" unless @ARGV == 2;

open IN, "<$ARGV[0]" or die "Error: cannot open $ARGV[0]\n";

my ($file_name) = $ARGV[0] =~ /(.+)\.fa*s*t*q$/;
my $final_bp = $ARGV[1];

open OUT, ">$file_name.bp$final_bp.fastq" or die "Error: cannot create $file_name.bp$final_bp.fastq";

while (<IN>) {
	if ($_ =~ /^\@HWI/) {
		my ($seq_id) = $_;
		$_ = <IN>;
		my ($full_seq) = $_;
		$_ = <IN>;
		$_ = <IN>;
		my ($full_qual) = $_;
		chomp($seq_id, $full_seq, $full_qual);
		my $trunc_seq = substr($full_seq, 0, $final_bp);
		my $trunc_qual = substr($full_qual, 0, $final_bp);
		print OUT "$seq_id\n$trunc_seq\n\+\n$trunc_qual\n";
	}
}

close IN; close OUT;