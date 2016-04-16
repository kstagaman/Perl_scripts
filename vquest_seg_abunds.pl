#!/usr/bin/perl
# vquest_seg_abunds.pl
use strict; use warnings;
use Getopt::Long;

# use this quick script to get the abundances of certain segments assigned by VQUEST.
# THERE MUST BE ABUNDANCE NUMBERS IN THE SEQUENCE ID!

my $usage = "\n\tvquest_seg_abunds.pl [-h -o] -p <SEG PATTERN> -i <INPUT VQUEST FILE>\n\n";

# defaults
my $help;
my $outdir = './';
my $pattern;
my $infile;

GetOptions (
	'help!' => \$help,
	'o=s'   => \$outdir,
	'p=s'   => \$pattern,
	'i=s'   => \$infile,
) or die $usage;

die $usage unless $help or ($infile and $pattern);
if ($outdir !~ /\/$/) {$outdir = "$outdir\/"}


if ($help) {
	print $usage;
	print "\t# use this quick script to get the abundances of certain segments assigned by VQUEST.\n";
	print "\t# THERE MUST BE ABUNDANCE NUMBERS IN THE SEQUENCE ID!\n";
}
else {
	# global variables
	$pattern = uc $pattern;
	my %seg_abunds;
	my @segs;
	my ($filename) = $infile =~ /(.+)\.txt/;

	open (INF, "<$infile") or die "\n\tError: cannot open $infile\n\n";

	while (<INF>) {
		my ($seg) = /($pattern\d+\-\d+)/;
		my ($abund) = /\d+:(\d+)/;

		$seg_abunds{$seg} += $abund;
	}
	close INF;

	open (OUT, ">$filename.seg_abunds.txt") or die "\n\tError: cannot create $filename.seg_abunds.txt\n\n";
	print OUT "abund\tv.seg\n";

	@segs = sort {$seg_abunds{$b} <=> $seg_abunds{$a}} keys %seg_abunds;
	foreach my $seg (@segs) {
		print OUT "$seg_abunds{$seg}\t$seg\n";
	}
	close OUT;	
}  