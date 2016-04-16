#!/usr/bin/perl
# balance_gels.pl
use strict; use warnings;
use Getopt::Long;

my $usage = "\n\tbalance_gels.pl [-h] -f <gel mass by sample file> -i <isopropanol? y/n> -k <kit? qiagen/genejet>\n\n";

# defaults
my $help;
my $file;
my $iso;
my $kit;


GetOptions (
	'help!' => \$help,
	'f=s'   => \$file,
	'i=s'   => \$iso,
	'k=s'   => \$kit,
	) or die $usage;

die $usage unless $help or ($file and $iso and $kit);

if ($help) {print $usage}
else {
	# global variables
	my %gelMasses;
	my $x; # total volume multiplier
	my @smpls;
	my @bestComparisons;
	my @matched;
	my ($filename) = $file =~ /^(.+)\.txt$/;

	if    ($iso eq 'y') {
		if    ($kit eq 'qiagen')  {$x = 5}
		elsif ($kit eq 'genejet') {$x = 3}
		else {die $usage}
	}
	elsif ($iso eq 'n'){
		if    ($kit eq 'qiagen')  {$x = 4}
		elsif ($kit eq 'genejet') {$x = 2}
		else {die $usage}
	}
	else {
		die $usage;
	}

	open IN, "<$file" or die "\n\tError: cannot open $file\n\n";

	while (<IN>) {
		my ($smpl) = $_ =~ /^(.+)\t/;
		my ($mass) = $_ =~ /\t(\d+)$/;
		$gelMasses{$smpl} = $mass;
		push @smpls, $smpl;
		# print "$smpl\t$mass\n";
	}

	close IN;

	for (my $i=0; $i < @smpls-1; $i++) {
		next if (grep /$smpls[$i]/, @matched);
		my %diffs;

		for (my $j=$i+1; $j < @smpls; $j++){
			my $diff = abs($gelMasses{$smpls[$i]} - $gelMasses{$smpls[$j]});
			my $comparison = "$smpls[$i]\-$smpls[$j]";
			$diffs{$comparison} = $diff;
			# print "$smpls[$i]\t$smpls[$j]\t$diff\n";
		}
		my @sortedComps = sort {$diffs{$a} <=> $diffs{$b}} keys %diffs;
		# print "@sortedDiffs\n";
		TEST: for (my $k=0; $k < @sortedComps; $k++) {
			my ($match) = $sortedComps[$k] =~ /\-(.+)$/;
			unless (grep /$match/, @matched) {
				push @bestComparisons, $sortedComps[$k];
				push @matched, $match;
				last TEST;
			}
		}
	}

	open OUT, ">$filename.balanced.txt" or die "\n\tError: cannot create $filename.balanced.txt\n\n";
	print OUT "smpl\tgel mass\t${x}x vol\tbalance\n";

	foreach my $bestComparison (@bestComparisons) {
		my ($smpl1) = $bestComparison =~ /^(.+)\-/;
		my ($smpl2) = $bestComparison =~ /\-(.+)$/;
		my $mass1 = $gelMasses{$smpl1};
		my $mass2 = $gelMasses{$smpl2};
		my $vol1 = $x * $mass1;
		my $vol2 = $x * $mass2;
		my $bal1 = 0;
		my $bal2 = 0;

		if    ($vol1 > $vol2) {$bal2 = $vol1 - $vol2}
		elsif ($vol1 < $vol2) {$bal1 = $vol2 - $vol1}

		print OUT "$smpl1\t$mass1\t$vol1\t$bal1\n";
		print OUT "$smpl2\t$mass2\t$vol2\t$bal2\n\n";
	}

	close OUT;
}

