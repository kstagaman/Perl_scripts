#!/usr/bin/perl
# cat_vj_seqs.pl
use strict; use warnings;
use Getopt::Long;


my $usage = "\n\tcat_vj_seqs.pl [-h] -s <sample id> -r <reference file directory PATH>\n\n";

# defaults
my $help;
my $sample;
my $refdir = './';

GetOptions (
	'help!' => \$help,
	's=s'   => \$sample,
	'r=s'   => \$refdir,
) or die $usage;

die $usage unless $sample or $help;
if ($refdir !~ /\/$/) {$refdir = "$refdir\/"}

if ($help) {print $usage}
else {
	# "global" variables
	my %seg_assigns;

	my ($fwd) = glob "$sample*fwd*fa";
	my ($rev) = glob "$sample*rev*fa";
	my ($ref) = glob "$refdir$sample*concordance.csv";

	open REF, "<$ref" or die "\n\nError: cannot open $ref\n\n";
	$_ = <REF>;

	while (<REF>) {
		my ($seq_id) = /^$sample,(\w+),/;
		my ($vseg)   = /,(V\d{1,2}):/;
		my ($jseg)   = /\w,((Jm\d|\*)),[01],[01],[01],[01],[01]$/;
		
		$seg_assigns{$seq_id} = {V => $vseg, J => $jseg};
	}
	close REF;

	open FWD, "<$fwd" or die "\n\nError: cannot open $fwd\n\n";
	open REV, "<$rev" or die "\n\nError: cannot open $rev\n\n";
	open CAT, ">$sample.fr_cat.fa" or die "\n\tError: cannot create $sample.fr_cat.fa\n\n";
	open FOUT, ">$sample.fwd.relab.fa" or die "\n\tError: cannot create $sample.fwd.relab.fa\n\n";
	open ROUT, ">$sample.rev.relab.fa" or die "\n\tError: cannot create $sample.rev.relab.fa\n\n";

	my $l1;
	my $l2 = <REV>;

	while ($l1 = <FWD>) {

		if ($l1 =~ /^\>/ and $l2 =~ /^\>/) {
			my ($seq_id1) = $l1 =~ /^>(\w+)_[12]:/;
			my ($seq_id2) = $l2 =~ /^>(\w+)_[12]:/;
			
			if ($seq_id1 ne $seq_id2) {
				die "\n\tError: Sequences in fwd and rev files are not in same order
				\n\t\tfwd: $l1\n\t\trev: $l2\n\n";
			}

			my $seq1 = <FWD>;
			my $seq2 = <REV>;
			chomp ($seq1, $seq2);

			my $revcomp_seq2 = revcomp($seq2);

			my $len1 = length $seq1;
			my $len2 = length $revcomp_seq2;
			my $tot_len = $len1 + $len2;

			unless ($seg_assigns{$seq_id1}->{J} eq '*') {
				print CAT "\>$sample:$seq_id1:$seg_assigns{$seq_id1}->{V}:$seg_assigns{$seq_id1}->{J}:";
				print CAT "V=${len1}bp,J=${len2}bp,total=${tot_len}bp\n$seq1$revcomp_seq2\n";

				print FOUT "\>$sample:$seq_id1:$seg_assigns{$seq_id1}->{V}:${len1}bp\n$seq1\n";
				print ROUT "\>$sample:$seq_id2:$seg_assigns{$seq_id1}->{J}:${len2}bp\n$revcomp_seq2\n";
			}

		}

		$l2 = <REV>;
	}
}
close FWD; close REV; close CAT; close FOUT; close ROUT;



sub revcomp {
	my ($seq) = @_;
	$seq = uc($seq);
	my $rev = reverse($seq);
	$rev =~ tr/ACGTURYKMBVDH/TGCAAYRMKVBHD/; # makes complement
	return $rev;
}