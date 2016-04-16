#!/usr/bin/perl
# get_taxon_otus.pl
use strict; use warnings;
use Getopt::Long;

# Use this script to get all the sequence that comprise OTUs within a certain taxon (of any level)
# The list of OTUs is generated in R with top_taxa.R

my $usage = "\n\tUsage: get_taxon_otus.pl [-h -o] -l <otu_list TXT> -u <UC> -f <FASTA>\n\n";

# defaults
my $help;
my $outDir = './';
my $otuList;
my $uclust;
my $fasta;

GetOptions (
	'help!' => \$help,
	'o=s'   => \$outDir,
	'l=s'   => \$otuList,
	'u=s'   => \$uclust,
	'f=s'   => \$fasta,
	) or die $usage;

die $usage unless $help or ($otuList and $uclust and $fasta);
if ($outDir !~ /\/$/) {$outDir = "$outDir\/"}

if ($help) {help_txt()}
else {
	# 'global' variables
	my $taxon;
	my $outName;
	my @otus;
	my @seqIDs;
	my ($rank) = $otuList =~ /rank(\d+)/;

	open OTU, "<$otuList" or die "\n\tError: cannot open $otuList\n\n";
	$taxon = <OTU>;
	chomp $taxon;
	$outName = "${outDir}${rank}_${taxon}_seqs.fasta";

	while (<OTU>) {
		my ($otu) = /X(\d+)/;
		# print "OTU: $otu\n";
		push @otus, $otu;
	}
	close OTU;

	open UCL, "<$uclust" or die "\n\tError: cannot open $uclust\n\n";
	while (my $line = <UCL>) {
		if ($line =~ /^[SH]/) {
			my ($clustNum) = $line =~ /^[SH]\t(\d+)\t/;

			if (grep /^$clustNum$/, @otus) {
				my ($seqID) = $line =~ /\t(\S+)\t\S+$/;
				# print "Cluster & seqID: $clustNum\t$seqID\n";
				push @seqIDs, $seqID;
			}
		}
	}
	close UCL;

	open INF, "<$fasta" or die "\n\tError: cannot open $fasta\n\n";
	open OUT, ">$outName" or die "\n\tError: cannot create $outName\n\n";

	while (my $line = <INF>) {
		if ($line =~ /^\>/) {
			my ($seqID) = $line =~ /^\>(\S+)$/; ############

			if (grep /^$seqID$/, @seqIDs) {
				my ($smpl)  = $seqID =~ /^(\w+)\-\d/;
				my ($read)  = $seqID =~ /\-(\d+)\-/;
				my ($abund) = $seqID =~ /\-(\d+)$/; ############
				my $seq = <INF>;
				chomp $seq;
				print OUT "\>${smpl}_Read${read}|freq:$abund\n$seq\n"; ############
			}
		}
	}
	close INF; close OUT;

}


sub help_txt{
	print $usage;
	print "\t\t-h: this helpful help screen\n";
	print "\t\t-o: output directory PATH, default is current (./)\n";
	print "\t\t-l: list in TXT format of all OTUs that comprise a given taxon. Name of taxon should be in header of file\n";
	print "\t\t-u: a uclust ouput file (UC) containing seeds and hits\n";
	print "\t\t-f: a FASTA file containing all sequences of interest\n\n";
	print "\t# Use this script to get all the sequence that comprise OTUs within a certain taxon (of any level)\n";
	print "\t# The list of OTUs is generated in R with top_taxa.R\n";

	print "\n";
}