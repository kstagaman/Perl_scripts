#!/usr/bin/perl
# cat_fastx_lines.pl
use strict; use warnings;

# use this script to concatentate two FASTA files, line by line
# (i.e. Seq 1 from File A will be concatenated with Seq 1 from File B)

my $usage = "\n\tcat_fastx_lines.pl <FASTX_1> <FASTX_2>\n\n";


if ($ARGV[0] =~ /^\-he*l*p*$/) {print $usage}
elsif (@ARGV < 2) {die $usage}
else {
	my @line_counts;
	my $fileType = "A";
	if ($ARGV[0] =~ /fa*s*t*q/i) {$fileType = "Q"}

	foreach my $file (@ARGV) {
		my $line_count;
		if ($fileType eq "A") {
			$line_count = `grep -c "^>" $file`;
		}
		else {
			$line_count = `grep -c "^\@HWI" $file`;
		}
		chomp $line_count;
		# print "$line_count\n";
		push @line_counts, $line_count;
	}

	die "\n\tFiles do not contain the same number of sequences\n\n" if ($line_counts[0] != $line_counts[1]);

	my ($filename1) = $ARGV[0] =~ /(.+)\.fa*s*t*[aq]$/i;
	my ($filename2) = $ARGV[1] =~ /(.+)\.fa*s*t*[aq]$/i;

	open IN1, "<$ARGV[0]" or die "\n\tError: cannot open $ARGV[0]\n\n";
	open IN2, "<$ARGV[1]" or die "\n\tError: cannot open $ARGV[1]\n\n";
	open OUT, ">$filename1.$filename2.fa" or die "\n\tError: cannot create $filename1.$filename2.fa\n\n";

	while (my $line1 = <IN1>) {
		my $line2 = <IN2>;
		my ($header1) = $line1;
		my ($header2) = $line2;
		my $seq1 = <IN1>;
		my $seq2 = <IN2>;
		chomp($header1, $header2, $seq1, $seq2);

		# print "$header1\t$header2\n";
		# print "$seq1\n$seq2\n\n";
		if ($fileType eq "A") {
			print OUT "$header1|$header2\n${seq1}$seq2\n";
		}
		else {
			my $plus1 = <IN1>;
			my $plus2 = <IN2>;
			my $qual1 = <IN1>;
			my $qual2 = <IN2>;
			chomp($plus1, $plus2, $qual1, $qual2);

			print OUT "$header1|$header2\n${seq1}$seq2\n$plus1\n${qual1}$qual2\n";
		}

	}
	close IN1; close IN2; close OUT;
}