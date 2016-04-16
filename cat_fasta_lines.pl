#!/usr/bin/perl
# cat_fasta_lines.pl
use strict; use warnings;

# use this script to concatentate two FASTA files, line by line
# (i.e. Seq 1 from File A will be concatenated with Seq 1 from File B)

my $usage = "\n\tcat_fasta_lines.pl <FASTA A> <FASTA B>\n\n";


if ($ARGV[0] =~ /^\-he*l*p*$/) {print $usage}
elsif (@ARGV < 2) {die $usage}
else {
	my @line_counts;
	foreach my $file (@ARGV) {
		my $line_count = `grep -c "^>" $file`;
		chomp $line_count;
		# print "$line_count\n";
		push @line_counts, $line_count;
	}
	die "\n\tFiles do not contain the same number of sequences\n\n" if ($line_counts[0] != $line_counts[1]);
	my ($filename1) = $ARGV[0] =~ /(.+)\.fas*t*a*$/;
	my ($filename2) = $ARGV[1] =~ /(.+)\.fas*t*a*$/;

	open FA1, "<$ARGV[0]" or die "\n\tError: cannot open $ARGV[0]\n\n";
	open FA2, "<$ARGV[1]" or die "\n\tError: cannot open $ARGV[1]\n\n";
	open OUT, ">$filename1.$filename2.fa" or die "\n\tError: cannot create $filename1.$filename2.fa\n\n";

	while (my $line1 = <FA1>) {
		my $line2 = <FA2>;
		my ($header1) = $line1 =~ /^\>(.+)/;
		my ($header2) = $line2 =~ /^\>(.+)/;
		my $seq1 = <FA1>;
		my $seq2 = <FA2>;
		chomp $seq1; chomp $seq2;

		# print "$header1\t$header2\n";
		# print "$seq1\n$seq2\n\n";

		print OUT "\>$header1|$header2\n${seq1}$seq2\n";
	}
	close FA1; close FA2;
}