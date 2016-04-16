#!/usr/bin/perl
# get_igblasted_seqs.pl
use strict; use warnings;
use Getopt::Long;

# Use this script after running blast_output.pl to use the .blastout.stats.csv file from that script.
# This script goes back through the original fasta file, finds the seqs that blasted to Ig and puts them in a new fasta file.

my $usage = "\n\tUsage: get_igblasted_seqs.pl [options: -h] -i <in .fasta> -statdir <location of .stats.csv file>\n\n";

# Defaults
my $infile;
my $statdir;
my $help;

# Global variables
my $filename;
my $extension;
my %stats;

GetOptions (
	'i=s'       => \$infile,
	'statdir=s' => \$statdir,
	'help!'     => \$help,
) or die $usage;

die $usage unless $infile and $statdir or $help;

if ($help) {
	print $usage;
	print "\t\t-h: this helpful help screen\n";
	print "\t\t-i: the input fasta file containing all sequences that were blasted\n";
	print "\t\t-statdir: the path to the directory containing the .blastout.stat.csv file produced by blast_output.pl\n\n";
}
else {
	#check that the contents of files are correct
	open FACHECK, "<$infile" or die "\n\tError: cannot open $infile\n\n";
	$_ = <FACHECK>;
	if ($_ !~ /^\>\d/) {die "\n\t Input file not in expected fasta format.\n\n"};
	close FACHECK;

	open STATCHECK, "<${statdir}${infile}.blastout.stats.csv" or die "\n\tError: cannot open ${statdir}${infile}.blastout.stats.csv\n\n";
	$_ = <STATCHECK>;
	if ($_ !~ /^sample,/) {die "\n\t Stats file is not in expected format (header)"};
	$_ = <STATCHECK>;
	if ($_ !~ /[01],[01],[01]$/) {die "\n\t Stats file is not in expected format (data)"};
	close STATCHECK;

	# continue with matching
	($filename)  = $infile =~ /(.+)\.rem\.fa$|fa_1$|fa_2$/;
	($extension) = $infile =~ /\.(rem\.fa$|fa_1$|fa_2$)/;

	open INFA, "<$infile";
	open STAT, "<${statdir}${infile}.blastout.stats.csv";
	open OUTFA, ">$filename.ig.$extension" or die "\n\tError: cannot create $filename.ig.$extension\n\n";
 	$_ = <STAT>;

 	while (<STAT>) {
 		my @line = split ",";
 		$stats{$line[6]} = $line[10]; # $line[6] is the uniq.seq.num and $line[10] is the ig.hit (0 or 1)
 	}

 	close STAT;

 	while (<INFA>) {

 		if ($_ =~ /^\>/) {
 			my $id = $_;
 			my $seq = <INFA>;
 			chomp ($id, $seq);
 			my ($seqNum) = $id =~ /^\>(\d+):/;
 			
 			if ($stats{$seqNum} == 1) {
 				print OUTFA "$id\n$seq\n";
 			}

 		}
 	}

 	close INFA; close OUTFA;
}
