#!/usr/bin/perl
# get_top_shared_peak.pl
use strict; use warnings;
use Getopt::Long;

# use this script to get top shared peaks from entropy data from oligtyping `entropy-analysis` or after an interation of `oligotype`

my $usage = "\n\tget_top_shared_peak.pl[-h -o -a] -r \"<regex>\" -n <output name>\n\n";

# defaults
my $help;
my $outDir = './';
my $avg;
my $regex;
my $outName;

GetOptions (
	'help!' => \$help,
	'o=s'   => \$outDir,
	'avg!'   => \$avg,
	'r=s'   => \$regex,
	'n=s'   => \$outName,
	) or die $usage;

die $usage unless $help or ($regex and $outName);
if ($outDir !~ /\/$/) {$outDir = "$outDir\/"}

if ($help) {print $usage}
else {
	#'global' variables
	my %peak_totals;
	my %peak_counts;
	my @files = glob $regex;
	my $outFile = "${outDir}$outName";

	foreach my $file (@files) {
		open INF, "<$file" or die "\n\tError: cannot open $file\n\n";
		while (<INF>) {
			my $line = $_;
			my @elements = split ("\t", $line);
			$peak_totals{$elements[0]} += $elements[1];
			$peak_counts{$elements[0]}++;
		}
		close INF;
	}
	my @peaks = sort {$peak_totals{$b} <=> $peak_totals{$a}} keys %peak_totals;
	open OUT, ">$outFile" or die "\n\tError: cannot create $outFile\n\n";
	if ($avg) {
		print OUT "position\tavg_height\n";
	} else {
		print OUT "position\ttotal_height\n";
	}

	foreach my $peak (@peaks) {
		if ($avg) {
			my $avg_height = $peak_totals{$peak} / $peak_counts{$peak};
			print OUT "$peak\t$avg_height\n";
		} else {
			print OUT "$peak\t$peak_totals{$peak}\n";
		}
	}
	close OUT;

}