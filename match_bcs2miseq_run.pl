#!/usr/bin/perl
# match_bcs2miseq_run.pl
use strict; use warnings;
use Getopt::Long;

# Use this script to match sorted uniq barcodes from the two middle files from a MiSeq run to your own barcode set.

my $usage = "\n\tmatch_bcs2miseq_run.pl [-h -o] -u <uniq barcodes> -b <expected barcodes>\n\n";

# defaults
my $help;
my $outdir = './';
my $uniqfile;
my $bcfile;

GetOptions (
	'help!' => \$help,
	'o=s'   => \$outdir,
	'u=s'   => \$uniqfile,
	'b=s'   => \$bcfile,
) or die $usage;

die $usage unless $help or ($uniqfile and $bcfile);
if ($outdir !~ /\/$/) {$outdir = "$outdir\/"}

if ($help) {print $usage}
else {
	# global
	my %barcodes;
	my %uniqbcs;
	my ($filename) = $uniqfile =~ /(.+)\.txt$/;

	open BCS, "<$bcfile" or die "\n\tError: cannot open $bcfile\n\n";
	while (<BCS>) {
		my ($id) = /^(\w+)\t/;
		# print "$id\t";
		my ($bc) = /\t([ACGTN]+)$/;
		$barcodes{$bc} = $id;
		# print "$bc\n";
	}
	close BCS;

	open UNQ, "<$uniqfile" or die "\n\tError: cannot open $uniqfile\n\n";
	while (<UNQ>) {
		my ($count) = /^\s*(\d+)\s/;
		# print "$count\t";
		my ($bcseq) = /\s([ACGTN]+)$/;
		$uniqbcs{$bcseq} = $count;
		# print "$bcseq\n";
	}
	close UNQ;

	my @barcodes = sort {$barcodes{$a} cmp $barcodes{$b}} keys %barcodes;
	my @uniqbcs = sort {$uniqbcs{$b} <=> $uniqbcs{$a}} keys %uniqbcs;

	open OUT, ">${outdir}$filename.matches.txt" or die "\n\tError: cannot create ${outdir}$filename.matches.txt\n\n";
	print OUT "bc.id\tbc\tcount\n";

	foreach my $uniqbc (@uniqbcs) {
		if(grep /$uniqbc/, @barcodes) {
			print OUT "$barcodes{$uniqbc}\t$uniqbc\t$uniqbcs{$uniqbc}\n";
		}
	}
	close OUT;
}