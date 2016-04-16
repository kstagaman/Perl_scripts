#!/usr/bin/perl
# balance_gels2.pl
use strict; use warnings;
use Getopt::Long;

print "\n\tWarning: balance_gels.pl is preferable to this script!\n\n";

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
	my $x; # total volume multiplier
	my %gelMasses;
	my @smpls;
	my %allComparisons;
	my @sortedComparisons;
	my @used;
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

		for (my $j=$i+1; $j < @smpls; $j++){
			my $diff = abs($gelMasses{$smpls[$i]} - $gelMasses{$smpls[$j]});
			my $comparison = "$smpls[$i]\-$smpls[$j]";
			$allComparisons{$comparison} = $diff;
			# print "$smpls[$i]\t$smpls[$j]\t$diff\n";
		}
	}

	@sortedComparisons = sort {$allComparisons{$a} <=> $allComparisons{$b}} keys %allComparisons;

	# foreach my $comparison (@sortedComparisons) {
	# 	print "$comparison\t$allComparisons{$comparison}\n";
	# }

	open OUT, ">$filename.balanced2.txt" or die "\n\tError: cannot create $filename.balanced.txt\n\n";
	print OUT "smpl\tgel mass\t${x}x vol\tbalance\n";

	foreach my $comparison (@sortedComparisons) {
		my ($smpl1) = $comparison =~ /^(.+)\-/;
		my ($smpl2) = $comparison =~ /\-(.+)$/;

		next if (grep(/$smpl1/, @used) or grep(/$smpl2/, @used));
		push @used, $smpl1;
		push @used, $smpl2;
		# print "@used\n";
		
		my $mass1 = $gelMasses{$smpl1};
		my $mass2 = $gelMasses{$smpl2};
		my $vol1 = $x * $mass1;
		my $vol2 = $x * $mass2;
		my $bal1 = 0;
		my $bal2 = 0;

		if ($vol1 > $vol2)     {$bal2 = $vol1 - $vol2}
		elsif ($vol1 < $vol2) {$bal1 = $vol2 - $vol1}

		print OUT "$smpl1\t$mass1\t$vol1\t$bal1\n";
		print OUT "$smpl2\t$mass2\t$vol2\t$bal2\n\n";
	}

	close OUT;
}

