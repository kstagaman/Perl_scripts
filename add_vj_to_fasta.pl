#!/usr/bin/perl
# add_vj_to_fasta.pl
use strict; use warnings;

die "Usage: add_vj_to_fasta.pl <fasta> <?.V.taxonomy> <?.J[mz].taxonomy>\n" unless @ARGV == 3;

my ($filename) = $ARGV[0] =~ /(\w+)\.fas*t*a*/ or die "Error: first file listed is not fasta\n";

open VTAX, "<$ARGV[1]" or die "Error: cannot open $ARGV[1]\n";

my @vsegs;
while (<VTAX>) {
	my ($vseg) = $_ =~ /(V\d+)/;
	push @vsegs, $vseg;
}

close VTAX;


open JTAX, "<$ARGV[2]" or die "Error: cannot open $ARGV[2]\n";

my @jsegs;
while (<JTAX>) {
	my ($jseg) = $_ =~ /(J[mz]\d+)/;
	push @jsegs, $jseg;
}

close JTAX;


open FA, "<$ARGV[0]" or die "Error: cannot open $ARGV[0]\n";

my @ids;
my @seqs;
while (<FA>) {
	if ($_ =~ /^\>/) {
		my ($id) = $_;
		chomp $id;
		push @ids, $id;
		$_ = <FA>;
		my ($seq) = $_;
		chomp $seq;
		push @seqs, $seq;
	}
}

close FA;

open OUT, ">$filename\_vj.fa" or die "Error: cannot create $filename\_vj.fa\n";

for (my $i = 0; $i < @ids; $i++) {
	print OUT "$ids[$i]:$vsegs[$i]:$jsegs[$i]\n$seqs[$i]\n";
}

close OUT;