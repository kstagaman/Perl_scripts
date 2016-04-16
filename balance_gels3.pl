#!/usr/bin/perl
# balance_gels.pl
use strict; use warnings;
use Getopt::Long;
use Algorithm::Combinatorics 'permutations';

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

	my %all_bestComparisons;
	my %all_totalDiffs;
	my $perm_count = 0;

	# my @all_smpl_perms = permutations(\@smpls);
	# print "@all_smpl_perms\n";
	my @all_smpl_perms;
	my @used_randices;
	my $smpl_count = @smpls;
	my $subset_count = 0;

	until (@all_smpl_perms == @smpls / 2) {
		my @smpl_perm;
		my @used_randices;

		until (@smpl_perm == @smpls) {
			my $randex = int rand $smpl_count;
			# $|++; print "randex: $randex\n";

			unless(grep /$randex/, @used_randices) {
				push @used_randices, $randex;
				push @smpl_perm, $smpls[$randex];
			}
		}
		$|++; print "@used_randices\n";

		unless(grep /@smpl_perm/, @all_smpl_perms){
			@{$all_smpl_perms[$subset_count]} = @smpl_perm;
			$subset_count++;
		}
	}
	# foreach my $sub_smpl_perm (@all_smpl_perms) {
	# 	print "@{$sub_smpl_perm}\n";
	# }

	foreach my $smpl_perm (@all_smpl_perms) {
		$perm_count++;
		# print "permutation: @{$smpl_perm}\n";
		my @matched;
		my @perm_bestComparisons;
		my $perm_totalDiffs = 0;


		for (my $i=0; $i < @{$smpl_perm}-1; $i++) {
			next if (grep /$smpls[$i]/, @matched);
			my %diffs;

			for (my $j=$i+1; $j < @{$smpl_perm}; $j++){
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
					push @perm_bestComparisons, $sortedComps[$k];
					# print "$sortedComps[$k]\n";
					$perm_totalDiffs += $diffs{$sortedComps[$k]};
					push @matched, $match;
					last TEST;
				}
			}
		}
		my $perm_bestComparisons_name = "$perm_count";
		# print "$perm_bestComparisons_name\n";
		@{$all_bestComparisons{$perm_bestComparisons_name}} = @perm_bestComparisons;
		$all_totalDiffs{$perm_bestComparisons_name} = $perm_totalDiffs;
	}
	my @sorted_all_totalDiffs = sort {$all_totalDiffs{$a} <=> $all_totalDiffs{$b}} keys %all_totalDiffs;
	my $min_diff = $sorted_all_totalDiffs[0];
	# print "smallest_diff: $all_totalDiffs{$min_diff}\n";
	my @bestPermutation = @{$all_bestComparisons{$min_diff}};
	# print "best permutation: @bestPermutation\n";


	open OUT, ">$filename.balanced3.txt" or die "\n\tError: cannot create $filename.balanced3.txt\n\n";
	print OUT "smpl\tgel mass\t${x}x vol\tbalance\n";

	foreach my $smpl_pair (@bestPermutation) {
		my ($smpl1) = $smpl_pair =~ /^(.+)\-/;
		my ($smpl2) = $smpl_pair =~ /\-(.+)$/;
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

