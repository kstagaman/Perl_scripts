#!/usr/bin/perl
# build_otu_table_OLD.pl
use strict; use warnings;
use Getopt::Long;

# use this script to generate an OTU table from a UCLUST .uc output file

my $usage = "\n\tusage: build_otu_table.pl [ -h -o <output PATH> ] -i <UC file>\n\n";

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
die unless $help or $inFile;

if ($help) {
	help_txt();
}
else {
	# global variables
	my ($outName) = $inFile =~ /\/*([\w\.]+)\.uc$/;
	my %seeds_by_seqIDs;
	my @seeds;
	my %seqIDs_by_smpl;
	my @smpls;
	my %abunds_by_seqID;
	my %clusterIDs_by_seed;

	open INF, "<$inFile" or die "\n\tError: cannot open $inFile\n\n";
	while (<INF>) {
		if ($_ =~ /^[SHL]/) {
			my ($type)        = /^([SHL])\t/;
			# print "type: $type\t";
			my ($clusterID)   = /^$type\t(\d+)\t/;
			# print "clusterID: $clusterID\t";
			my ($targetLabel) = /\t(\S+)$/;
			# print "targetLabel: $targetLabel\t";
			my ($queryLabel)  = /\t(\S+)\t\S+$/;
			# print "queryLabel: $queryLabel\n";

			my ($smpl, $seqID, $abund);
			if ($type eq 'L') {
				$smpl = 'GreenGenes';
				$seqID = $queryLabel;
				$abund = 0;
			} else {
				($smpl)  = $queryLabel =~ /^(\w+)\-/;
				($seqID) = $queryLabel =~ /^(\w+\-\d+)\-/;
				($abund) = $queryLabel =~ /\-(\d+)$/;
			}

			$abunds_by_seqID{$seqID} = $abund;
			push @{$seqIDs_by_smpl{$smpl}}, $seqID;

			if ($type eq 'S' or $type eq 'L') {
				$seeds_by_seqIDs{$seqID} = $seqID;
				$clusterIDs_by_seed{$seqID} = $clusterID;
				push @seeds, $seqID;
			}
			else {
				my ($seed) = $targetLabel =~ /^(\w*\-*\d+)\-*/;
				$seeds_by_seqIDs{$seqID} = $seed;
			}
		}
	}
	close INF;

	@smpls = sort keys %seqIDs_by_smpl;

	my %taxon_abunds;
	foreach my $seed (@seeds) {
		my $taxon = "X$clusterIDs_by_seed{$seed}";
		$taxon_abunds{$taxon} = 0;
	}
	my @taxa = sort keys %taxon_abunds;

	open OUT, ">${outDir}${outName}.otu_tbl.txt" or die "\n\tError: cannot create ${outDir}${outName}.otu_tbl.txt\n\n";
	my $columnHeader = join "\t", @taxa;
	print OUT "\t$columnHeader\n";

	foreach my $smpl (@smpls) {
		$taxon_abunds{$_} = 0 for @taxa;
		print OUT "$smpl";

		foreach my $seqID (@{$seqIDs_by_smpl{$smpl}}) {
			my $taxon = "X$clusterIDs_by_seed{$seeds_by_seqIDs{$seqID}}";
			my $abund = $abunds_by_seqID{$seqID};
			$taxon_abunds{$taxon} += $abund;
		}

		foreach my $taxon (@taxa) {
			print OUT "\t$taxon_abunds{$taxon}";
		}

		print OUT "\n";

	}
	close OUT;
}

sub help_txt {
	print $usage;
}