#!/usr/bin/perl
# cat_aligned_vj_segs.pl
use strict; use warnings;


# make sure Jm segs are already reverse complemented before concatenating

# this script only works if files containing V and J segs are in same order and have the same
# number of sequences.


my $usage = "\n\tUsage: cat_aligned_vj_segs.pl <V segs FASTA> <J segs FASTA>\n\n";

die $usage unless @ARGV == 2;

my ($smpl_id) = $ARGV[1] =~ /^(\S+)\.[VJ]/;

open VS, "<$ARGV[0]" or die "\n\tError: cannot open $ARGV[0]\n\n";
open JS, "<$ARGV[1]" or die "\n\tError: cannot open $ARGV[1]\n\n";
open OUT, ">$smpl_id.VJ.cat.fa" or die "\n\tError: cannot create all_V$jtype.cat.fa\n\n";

my $vline;
my $jline = <JS>;

while ($vline = <VS>) {

	if ($vline =~ /^\>/ and $jline =~ /^\>/) {
		my ($id)   = $vline =~ /^\>([mz][abcd]\d{2}:\w+):V/;
		my ($vseg) = $vline =~ /^\>$id:(V\d{2}):/;
		my ($jseg) = $jline =~ /^\>$id:(J[mz]\d):/;
		my ($vlen) = $vline =~ /:(\d+)bp$/;
		my ($jlen) = $jline =~ /:(\d+)bp$/;
		my $vseq = <VS>;
		my $jseq = <JS>;

		my $total_len = $vlen + $jlen;
		chomp ($vseq, $jseq);

		print OUT "\>$id:$vseg:$jseg:$vlen\+$jlen\=${total_len}bp\n$vseq$jseq\n";

		$jline = <JS>;
	}
}

close VS; close JS; close OUT;