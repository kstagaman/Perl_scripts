#!/usr/bin/perl
# snippet_examples.pl
use strict; use warnings;

my $usage = "\n\tUsage: snippet_examples.pl [-h] -i <infile>\n\n";

# defaults
my $help;
my $outDir = './';
my $inFile;

GetOptions (
	'help!' => \$help,
	'o=s'   => \$outDir,
	'i=s'   => \$inFile,
	) or die $usage;

if ($outDir !~ /\/$/) {$outDir = "$outDir\/"}
die unless $help or ($inFile);

if ($help) {
	help_txt();
}
else {
	
}

sub help_txt {
	print $usage;
}