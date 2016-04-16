#!/usr/bin/perl
# rnafold_predictions.pl
use strict; use warnings;
use Getopt::Long;

# use this script to get the various predicted energies, structures, etc from an RNAfold output file
# make sure the input file ends in "*RNAfold.out" (case is ignored)

my $usage = "\n\trnafold_predictions.pl [-h -o] -i <input file>\n\n";

# defaults
my $help;
my $outdir = './';
my $infile;

GetOptions (
	'help!' => \$help,
	'o=s'   => \$outdir,
	'i=s'   => \$infile,
) or die $usage;

die $usage unless $help or $infile;
if ($outdir !~ /\/$/) {$outdir = "$outdir\/"}


if ($help) {print $usage}
else {
	# global variables
	die "\n\tFile name must end in \*RNAfold.out (case is ignored)\n\n" unless ($infile =~ /\.RNAfold\.out$/i);
	my ($filename) = $infile =~ /(.+)\.RNAfold\.out$/i;

	open INF, "<$infile" or die "\n\tError: cannot open $infile\n\n";
	open OUT, ">${outdir}$filename.RNAfold_predictions.txt" or die "\n\tError: cannot create ${outdir}$filename.RNAfold_predictions.txt\n\n";
	print OUT "vdj\tabund\toptimal.min.free.energy\tfree.energy.of.thermodyn.ensemble\tcentroid.min.free.energy\tcentroid.d\tfreq.of.mfe.structure\tensemble.diversity\n";
	my $lineCount = 0;
	while (<INF>) {
		if ($_ =~ /^\>/) {
			$lineCount++;
			if ($lineCount % 1000 == 0) {
				$|++;
				print "\r$lineCount";
			}
			my ($seq_name) = $_ =~ /^\>(.+)$/;
			my ($abund) = $seq_name =~ /\W(\d+)\W/;
			if (!$abund) {$abund = "NA"}; 
			my ($v) = $seq_name =~ /(V\d+\-*\d*)/;
			my ($d) = $seq_name =~ /(D\d+\-*\d*)/;
			if (!$d) {$d = "no_D"}
			my ($j) = $seq_name =~ /(J\d+\-*\d*)/;
			my $vdj = "${v}${d}${j}";

			$_ = <INF>;
			$_ = <INF>;
			my ($omfe)     = $_ =~ /\(\s*(\-*\d+\.*\d*)\)$/;
			# print "$omfe\n";
			$_ = <INF>;
			my ($fete)     = $_ =~ /\[\s*(\-*\d+\.*\d*)\]$/;
			# print "$fete\n";
			$_ = <INF>;
			my ($cmfe)     = $_ =~ /\{\s*(\-*\d+\.*\d*)\sd=/;
			# print "$cmfe\n";
			my ($cmfe_d)   = $_ =~ /d=(-*\d+\.*\d*)\}$/;
			# print "$cmfe_d\n";
			$_ = <INF>;
			my ($freq)     = $_ =~ /in ensemble (\d+\.*\d*e*\-*\d*)\;/;
			# print "$freq\n";
			my ($ediv)     = $_ =~ /diversity (\d+\.*\d*)\s*$/;
			# print "$ediv\n";

			print OUT "$vdj\t$abund\t$omfe\t$fete\t$cmfe\t$cmfe_d\t$freq\t$ediv\n";
		}
	}
	close INF; close OUT;
	print "\r$lineCount\n";
}