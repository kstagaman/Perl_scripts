#!/usr/bin/perl
# classify_seqs_v_commands.pl
use strict; use warnings;

# use this script to generate commands required to run classify.seqs in mothur for V segs.

die "Usage: classify_seqs_v_commands.pl <in files expr> <out file name>\n" unless @ARGV == 2;

my @files = `ls *$ARGV[0]`;
chomp @files;

my $outfile = $ARGV[1];

open OUT, ">$outfile.txt" or die "Error: cannot create $outfile.txt\n";

print OUT "ksize = 3\n\n";

foreach my $file (@files) {
	print OUT "classify.seqs(fasta=$file, reference=V.fa, taxonomy=V.taxonomy, ksize=3)\n";
}

print OUT "\nksize 4\n\n";

foreach my $file (@files) {
	print OUT "classify.seqs(fasta=$file, reference=V.fa, taxonomy=V.taxonomy, ksize=4)\n";
}

print OUT "\nksize 6\n\n";

foreach my $file (@files) {
	print OUT "classify.seqs(fasta=$file, reference=V.fa, taxonomy=V.taxonomy, ksize=6)\n";
}

print OUT "\nksize = 8\n\n";

foreach my $file (@files) {
	print OUT "classify.seqs(fasta=$file, reference=V.fa, taxonomy=V.taxonomy, ksize=8)\n";
}

print OUT "\nksize = 10\n\n";

foreach my $file (@files) {
	print OUT "classify.seqs(fasta=$file, reference=V.fa, taxonomy=V.taxonomy, ksize=10)\n";
}


close OUT;