#!/usr/bin/perl
# primer_match.pl
use strict; use warnings;
use Getopt::Long;
use Good_library;

# Use this script to find sequences with an exact primer match, allowing for a certain amount
# of offset at the beginning
# This script gives the option to remove the primer from the seq
# This script gives the option to drop any sequences that would be under a certain
# length without the primer (whether it's removed or not)

my $usage = "\n\tUsage: primer_match.pl [-h -q -r -o <PATH> -min <NUM> -f <NUM>] -p <primer FASTA> -i <input FASTA>\n\n";

# defaults
my $help;
my $quiet;
my $remove;
my $outdir = './';
my $minlen = 1;
my $offset = 0;
my $primerfile;
my $infile;

GetOptions (
	'help!'   => \$help,
	'quiet!'  => \$quiet,
	'remove!' => \$remove,
	'o=s'     => \$outdir,
	'min=i'   => \$minlen,
	'f=i'     => \$offset,
	'p=s'     => \$primerfile,
	'i=s'     => \$infile,
) or die "bad options:$usage";

die $usage unless $help or ($primerfile and $infile);
if ($outdir !~ /\/$/) {$outdir="$outdir\/"}

if ($help) {help_txt()}
else {
	# get primers
	my %primer_names;
	my @primers;

	open PRM, "<$primerfile" or die o_err($primerfile);

	while (<PRM>) {

		if ($_ =~ /^\>/) {
			my ($name) = /^\>(\S+)/;
			my $primer = <PRM>;
			chomp $primer;

			$primer_names{$primer} = $name;
		}
	}
	close PRM;

	@primers = sort {$primer_names{$a} cmp $primer_names{$b}} keys %primer_names;

	# get seqs with primers, drop short, etc.

	my $seq_count = 0;

	open CNT, "<$infile" or die o_err($infile);

	while (<CNT>) {

		if ($_ =~ /^\>/) {
			$seq_count++;
		}
	}
	close CNT;

	print "$infile:\n\ttotal: $seq_count\n" unless $quiet;

	my ($filename) = $infile =~ /(\S+)\.fa$/;

	my $short_count = 0;

	foreach my $primer (@primers) {
		my $outfile = "$outdir$filename.$primer_names{$primer}.fa";
		open OUT, ">$outfile" or die o_err($outfile);
		open INF, "<$infile"  or die o_err($infile);
		my $primer_count = 0;

		while (<INF>) {

			if ($_ =~ /^\>/) {
				my $seqid   = $_;
				my $fullseq = <INF>;
				chomp ($seqid, $fullseq);
				
				my $seq;

				if ($fullseq =~ /^[ACGT]{0,$offset}$primer/) {
					my ($front) = $fullseq =~ /^([ACGT]{0,$offset}$primer)/;
					my ($back)  = $fullseq =~ /^[ACGT]{0,$offset}$primer([ACGT]+)/;

					if (!$back or length $back < $minlen) {
						$short_count++;
					} else {

						if ($remove) {
							$seq = $back;
						} else {
							$seq = $fullseq;
						}
					}
				}
				
				print OUT "$seqid\n$seq\n" unless !$seq;

				$primer_count++ unless !$seq;
			}
		}
		close OUT; close INF;

		print "\t$primer_names{$primer}: $primer_count\n" unless $quiet;
	}

	print "\tshort: $short_count\n" unless $quiet;
}




sub help_txt {
	print $usage;
	print "\t\t-h:\tthis helpful help screen\n\n";

	print "\t\tINPUT:\n";
	print "\t\t-p\tFASTA file containing primer sequences\n";
	print "\t\t-i\tFASTA file containing input sequences\n\n";

	print "\t\tOPTIONS:\n";
	print "\t\t-q\tquiet, suppress output to STDOUT\n";
	print "\t\t-r\tremove primers from the sequences\n";
	print "\t\t-o\toutput path, default current directory\n";
	print "\t\t-min\tminimum length of sequence not including primer (even if primer is not removed)\n";
	print "\t\t\tdefault is 1\n";
	print "\t\t-f\tmaximum offset from beginning of sequence that the primer can start, default is 0\n\n";


}