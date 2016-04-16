#!/usr/bin/perl
# vdj_assign2delim.pl
use strict; use warnings;
use Getopt::Long;

# use this script to take V, D, J assigments from Emily and put them into a delimited file easy to load into R

my $usage = "\n\tvdj_assign2delim.pl [-h -d <delimiter> -o <output path> -s <suffix] -i <input file>\n\n";

# defaults

my $help;
my $delim = "\t";
my $outPath = './';
my $inFile;
my $suffix = 'tsv';

GetOptions(
	'help!' => \$help,
	'd=s'   => \$delim,
	'o=s'   => \$outPath,
	'i=s'   => \$inFile,
	's=s'   => \$suffix,
) or die $usage;

die $usage unless $help or $inFile;
if ($outPath !~ /\/$/) {$outPath = "$outPath\/"}

if ($help) {help_text()}
else{
	# global variables
	my ($fileName) = $inFile =~ /(.+)\.txt$/;
	if ($delim eq ',') {$suffix = 'csv'}

	open INF, "<$inFile" or die "\n\tError: cannot open $inFile\n\n";
	open OUT, ">$outPath$fileName.$suffix" or die "\n\tError: cannot create $outPath$fileName.$suffix";

	print OUT "smpl${delim}V.seg${delim}D.seg${delim}J.seg${delim}V.D.J${delim}abund\n";

	while (<INF>) {
		my ($v) = /(V\d+-\d+)/;
		my ($d) = /(D\d-\d)/;
		my ($j) = /(J\d-\d)/;
		my ($abund) = /F\|(\d+)\|/;
		my ($smpl) = /\|(\w+)$/;

		print OUT "$smpl${delim}$v${delim}$d${delim}$j${delim}$v:$d:$j${delim}$abund\n";
	}
	close INF; close OUT;
}


sub help_text {
	print $usage;
	print "\t\t-h: this helpful help screen\n";
	print "\t\t-d: delimiter to use in output file, default is \\t (tab)\n";
	print "\t\t-o: directory in which to put the output file, default is current\n";
	print "\t\t-s: suffix to put on the end of the output\n\t\t    if delimiter is \\t or ',' then .tsv or .csv (respectively) will be added automatically\n";
	print "\t\t-i: the input file\n";

}