#!/usr/bin/perl
# assign_vdj.pl
use strict; use warnings;

die "Usage: assign_vdj.pl <candidates file> <reference file>" unless @ARGV == 2;

open REF, "<$ARGV[1]" or die "Error: cannot open reference file";

my @refseqs = ();
my $i = 0;

while (<REF>) {
	if ($_ =~ /^\>/) {
		my ($fid) = $_ =~ /^\>\|\:(\w+\|*\w*\|*\w*\|*\w*\|*\w*)\;/;
		my ($v)   = $_ =~ /^\>\|\:\w+\|*\w*\|*\w*\|*\w*\|*\w*\;(\d{1,2})\;/;
		my ($d)   = $_ =~ /^\>\|\:\w+\|*\w*\|*\w*\|*\w*\|*\w*\;\d{1,2}\;(\d{1})\;/;
		my ($j)   = $_ =~ /^\>\|\:\w+\|*\w*\|*\w*\|*\w*\|*\w*\;\d{1,2}\;\d{1}\;(\d{1})\;/;
		$_ = <REF>;
		my ($rseq) = uc($_); chomp $rseq;
		$refseqs[$i] = {fish => $fid, V => $v, D => $d, J => $j, rseq => $rseq};
		$i++;
	}
}

close REF;

open CAN, "<$ARGV[0]" or die "Error: cannot open candidates file";

my @candidates = ();
my $k = 0;


while (<CAN>) {
	if ($_ =~ /^\>/) {
		my ($id) = $_;
		$_ = <CAN>;
		my ($seq) = $_ =~ /(\w+)/;
		chomp $id;
#		print "$seq\n";
		my $cseq = reverse $seq;
		$cseq =~ tr/ACGTURYKMBVDH/TGCAAYRMKVBHD/;
#		print "$cseq\n";
		$candidates[$k] = {ID => $id, cseq => $cseq};
		$k++;
	}
}

close CAN;

open OUT, ">assigned_candidates.fa";
my $l = 1;
my $ctotal = @candidates;
my $rtotal = @refseqs;

foreach my $candidate (@candidates) {
#	print "$k of $ctotal candidates\n";
	$l++;
	foreach my $refseq (@refseqs) {
		if ($refseq->{rseq} =~ /$candidate->{cseq}/) {
		print OUT "$refseq->{fish}\:V$refseq->{V}\:D$refseq->{D}\:J$refseq->{J}\: \-$candidate->{ID}\n";
		}
	}
}

close OUT;