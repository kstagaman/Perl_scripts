#!/usr/bin/perl
# divide_fwd_seqs.pl
use strict; use warnings;

# Use this script after get_cs_assignments.pl or primer_check.pl to divide up the *.fwd.* FASTA file
my $usage = "\n\tUsage: divide_fwd_seqs.pl <fwd FASTA file> <output directory PATH>\n\n";

die $usage unless @ARGV == 2;

my $infile = $ARGV[0];
my $outdir = $ARGV[1];
if ($outdir !~ /\/$/) {$outdir = "$outdir\/"}

my ($filename)  = $infile =~ /^(\S+)\.fwd/;
my ($ig_type)   = $infile =~ /^([mz])/;
my ($extension) = $infile =~ /fwd\.((fa_1|fa_2|rem.fa|fa))$/;

open IN, "<$infile" or die "\n\tError: cannot open $infile\n\n";

while (<IN>) {

	if ($_ =~ /^\>/) {
		my ($id) = /^\>(\S+)/;
		my ($primer) = /:(fwd_\d{1,2})$/;
		my $seq = <IN>;
		chomp $seq;
		open OUT, ">>${outdir}ig$ig_type.$primer.fa" or die "\n\tError: cannot open $filename.$primer.$extension\n\n";
		print OUT "\>$filename.$extension:$id\n$seq\n";
		close OUT;
	}
}

close IN;

print "$infile done\n";