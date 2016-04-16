#!/usr/bin/perl
# size_select.pl
use strict; use warnings;
use Getopt::Long;

# use this script to select sequences from a FASTA file equal to/greater than/less than a certain length

my $usage = "\n\tsize_select.pl [-h -o <output PATH> -g -l -e] -n <length> -i <input FASTA>\n\n";

# defaults
my $help;
my $outDir = './';
my $gt;
my $lt;
my $et;
my $bp;
my $inFile;

GetOptions(
	'help!' => \$help,
	'o=s'   => \$outDir,
	'gt!'   => \$gt,
	'lt!'   => \$lt,
	'et!'   => \$et,
	'n=i'   => \$bp,
	'i=s'   => \$inFile,
	) or die $usage;

die $usage unless $help or ($bp and $inFile);
if ($outDir !~ /\/$/) {$outDir = "$outDir\/"}

if ($help) {help_txt()} 
else {
	# global variables
	my $operator;
	my $outOp;

	if    ($gt and $et) {
		$operator = '>=';
		$outOp = 'gte';
	}
	elsif ($gt) {
		$operator = '>';
		$outOp = 'gt';
	}
	elsif ($lt and $et) {
		$operator = '<=';
		$outOp = 'lte';
	}
	elsif ($lt) {
		$operator = '<';
		$outOp = 'lt';
	}
	else {
		$operator = '==';
		$outOp = '';
	}

	my ($name) = $inFile =~ /(.+)\.fa*s*t*a$/;
	my $outFile = "$name.${outOp}${bp}bp.fasta";

	open INF, "<$inFile" or die "\n\tError: cannot open $inFile\n\n";
	open OUT, ">${outDir}$outFile" or die "\n\tError: cannot create ${outDir}$outFile\n\n";

	while (<INF>) {
		if ($_ =~ /^\>/) {
			my $hdr = $_;
			my $seq = <INF>;
			chomp ($hdr, $seq);
			my $len = length $seq;

			if (eval ("$len $operator $bp")) {
				print OUT "$hdr\n$seq\n";
			}
		}
	}
	close INF; close OUT;
}

sub help_txt {
	print $usage;
	print "\t\t-h: this helpful help screen\n";
	print "\t\t-o: the output directory, default is current (./)\n";
	print "\t\t-g: select sequences greater than -n\n";
	print "\t\t-l: select sequences less than -n\n";
	print "\t\t-e: with -g or -l, include sequences equal to -n\n";
	print "\t\t-n: reference length of sequences. Alone, sequences equal to this length will be selected\n";
	print "\t\t-i: input file in FASTA format\n\n";
}