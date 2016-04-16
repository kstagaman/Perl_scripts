#!/usr/bin/perl
# ig_orfs.pl
use strict; use warnings;
use Getopt::Long;

# use this script to separate sequences into pre- and post-first-ATG

my $usage = "\n\tig_orfs.pl [-h -o] -i <FASTA file>\n\n";

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

if ($outdir !~ /\/$/) {$outdir="$outdir\/"}

if ($help) {
	print $usage;
	help_txt();
}
else {
	# global variables
	my ($filename) = $infile =~ /^(\S+)\.fa$/;

	open INF, "<$infile" or die "\n\tError: cannot open $infile\n\n";
	open PRE, ">${outdir}$filename.pre-orf.fa" or die "\n\tError: cannot create ${outdir}$filename.pre-orf.fa\n\n";
	open ORF, ">${outdir}$filename.orfs.fa" or die "\n\nError: cannot create ${outdir}$filename.orfs.fa\n\n";

	while (<INF>) {
		if ($_ =~ /^\>/) {
			my $hdr = $_;
			my $seq = <INF>;
			chomp $hdr; chomp $seq;

			my $orf;
			my $pre;

			($orf) = $seq =~ /(ATG[ACGTN]+)$/;

			if ($orf){
				($pre) = $seq =~ /^([ACGTN]*)$orf$/;
			}
			else     {
				$pre = $seq;
				$orf = "no_ORF";
			}

			print PRE "$hdr\n$pre\n";
			print ORF "$hdr\n$orf\n";
		}
	}
	close INF; close PRE; close ORF;
}

sub help_txt{
	print "\t\t-h: the helpful help screen\n";
	print "\t\t-o: output director, default is current\n";
	print "\t\t-i: the input FASTA file\n";
}