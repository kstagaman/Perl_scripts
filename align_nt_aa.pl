#!/usr/bin/perl
# align_nt_aa.pl
use strict; use warnings;

my $usage = "\n\talign_nt_aa.pl <nt seq> <aa seq>\n\n";

die $usage unless @ARGV == 2;

my $ntseq = uc $ARGV[0];
my $aaseq = uc $ARGV[1];

my $nt_len = length $ntseq;
my $aa_len = length $aaseq;
my $len_check = $nt_len / $aa_len;

if ($len_check != 3) {

	if ($len_check > 3) {
		print STDERR "\n\tThe aa seq is shorter than expected. Proceed? ";
	}
	else {
		print STDERR "\n\tThe aa seq is longer than expected. Proceed? ";
	}

	chomp(my $answer = <STDIN>);

	while ($answer !~ /^(ye*s*|no*)$/) {
		print STDERR "\n\t Answer yes/no, please ";
		$answer = <STDIN>;
		chomp $answer;
	}

	if ($answer =~ /no*/) {die "\talign_nt_aa.pl aborted\n\n"}
}

my $spaced_aas = join('  ', split('', "$aaseq"));
$spaced_aas = " $spaced_aas ";

# print length($ntseq), "\n";
# print length($spaced_aas), "\n";

my $num_subseqs = length($ntseq) / 102;

for (my $i = 0; $i < $num_subseqs; $i++) {
	my $start = $i * 102;
	my $subnt = substr $ntseq, $start, 102;
	my $subaa = substr $spaced_aas, $start, 102;

	print "$subnt\n";
	print "$subaa\n";
	print "\n";
}

