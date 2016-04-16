#!/usr/bin/perl
# simple_uniq_seqs.pl
use strict; use warnings;
use Getopt::Long;

# use this script to output unique sequences and their abundances contained in a FASTA file

my $usage = "\n\tsimple_uniq_seqs.pl [-h -o <output PATH>] -i <FASTA>\n\n";

# defaults
my $help;
my $outdir = './';
my $infile;

GetOptions(
	'help!' => \$help,
	'o=s'   => \$outdir,
	'i=s'   => \$infile,
) or die $usage;

die $usage unless $help or $infile;
if ($outdir !~ /\/$/) {$outdir = "$outdir\/"}

if ($help) {print $usage}
else {
	# global variables
	my ($filename) = $infile =~ /(.+)\.fa$/i;
	my %abunds_by_seq;
	my @uniq_seqs;

	open INF, "<$infile" or die "\n\tError: cannot open $infile\n\n";

	while (<INF>) {
		if ($_ !~ /^\>/) {
			my $seq = $_;
			chomp $seq;

			$abunds_by_seq{$seq}++;
		}
	}
	close INF;

	@uniq_seqs = sort{$abunds_by_seq{$b} <=> $abunds_by_seq{$a}} keys %abunds_by_seq;
	my $num_uniqs = @uniq_seqs;
	my $max_digits = length "$num_uniqs";

	open OUT, ">${outdir}$filename.uniq.fa" or die "\n\tError: cannot create ${outdir}$filename.uniq.fa\n\n";
	my $count = 1;

	foreach my $uniq_seq (@uniq_seqs) {
		printf OUT "\>%.${max_digits}d:%d\n", $count, $abunds_by_seq{$uniq_seq};
		print OUT "$uniq_seq\n";
		$count++
	}
	close OUT;
}