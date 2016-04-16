#!/usr/bin/perl
# random_seqs.pl
use strict; use warnings;
use Getopt::Long;

# use this script to generate a certain number of random sequences of a certain length
# this script ouputs the sequences and their abundances in a tab-delimited file

my $usage = "\n\tUsage: random_seqs.pl [-h -o <output dir>] -n <number> -l <length>\n\n";

# defaults
my $help;
my $outdir = './';
my $n;
my $l;

GetOptions (
	'help!' => \$help,
	'o=s'   => \$outdir,
	'n=i'   => \$n,
	'l=i'   => \$l,
	) or die $usage;

if ($outdir !~ /\/$/) {$outdir = "$outdir\/"}
die $usage unless $help or ($n and $l);

if ($help) {
	print $usage
	print "Use this script to generate a certain number of random sequences of a certain length\n";
}
else {
	# global variables
	my %seqAbunds;
	my @nts = ('A', 'C', 'G', 'T');

	for (my $i=0; $i < $n; $i++) {
		my $seq;
		$seq .= $nts[rand @nts] for 1..$l;
		$seqAbunds{$seq}++;
	}

	open OUT, ">random_seqs_n${n}_l${l}.txt" or die "\n\tError: cannot create random_seqs_n${n}_l${l}.txt\n\n";

	my @seqs = sort {$seqAbunds{$a} <=> $seqAbunds{$b}} keys %seqAbunds;
	foreach my $seq (@seqs) {
		print OUT "$seq\t$seqAbunds{$seq}\n";
	}
	close OUT;
}