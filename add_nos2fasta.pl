#!/usr/bin/perl
# add_nos2fasta.pl
use strict; use warnings;
use Getopt::Long;

# use this script to add numbers to ID lines in a fasta file. Option -s allows you to specify the separator, default is '|'.
my $usage = "\n\tUsage: add_nos2fasta.pl [-h -s -o] -i\n\n";

my $help;
my $sep = '|';
my $outdir = './';
my $infile;

GetOptions(
	'help!' => \$help,
	's=s'   => \$sep,
	'o=s'   => \$outdir,
	'i=s'   => \$infile,
) or die $usage;

die $usage unless $help or $infile;
if ($outdir !~ /\/$/){$outdir = "$outdir\/"}

if ($help) {
	print $usage;
}
else {
	# global variables
	my ($name) = $infile =~ /(.+)\.fa$/;

	open(IN, "<$infile") or die "\n\tError: cannot open $infile\n\n";
	open(OUT, ">$name.numbered.fa") or die "\n\tError: cannot create $name.numbered.fa\n\n";

	my $i = 0;

	while (<IN>) {
		if ($_ =~ /^\>/) {
			my $line = $_;
			# print "$line\n";
			my @line = split("", $_);
			# print "@line\n";
			splice(@line, 1, 0, "$i$sep");
			# print "@line\n";
			my $newline = join("", @line);
			# print "$newline";
			print OUT "$newline";
			$i++;
		}
		else {
			print OUT "$_";
		}
	}
}

close IN; close OUT;