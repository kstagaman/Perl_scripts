#!/usr/bin/perl
# first_n_bp.pl
use strict; use warnings;
use Getopt::Long;
use Good_library;

# use this script to get the first n basepairs of all sequences in a FASTA file (does not work with FASTQ)

my $usage = "\n\tUsage: first_n_bp.pl [-h -o] -n NUM -f FASTA\n\n";

# defaults
my $help;
my $outdir = './';
my $num;
my $infile;

GetOptions (
	'help!' => \$help,
	'o=s'   => \$outdir,
	'n=i'   => \$num,
	'f=s'   => \$infile,
) or die $usage;

if ($outdir !~ /\/$/) {$outdir = "$outdir\/"}
die $usage unless $help or ($num and $infile);

if ($help) {print $usage}
else {
	my ($name) = $infile =~ /(\S+).fa$/;
	my $outfile = "$outdir$name.f$num.fa";
	open IN, "<$infile" or die o_err($infile);
	open OUT, ">$outfile" or die o_err($outfile);

	while (<IN>) {

		if ($_ =~ /^\>/) {
			my $id = $_;
			my $seq = <IN>;
			chomp ($id, $seq);

			my $firstn = substr ($seq, 0, $num);

			print OUT "$id\n$firstn\n";
		}
	}
	close IN; close OUT;
}