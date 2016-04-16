#!/usr/bin/perl
# uniq_mapped_by_smpl.pl
use strict; use warnings;
use Getopt::Long;

# Use this script on a single FASTA file containing sequences from multiple samples
# to collapse to unique sequences and generate a mapping file associating each unique
# sequence and its abundances with the samples it appears in

# Headers should follow the form: >SMPL-SEQ_NUMBER

# IF a mapping file is supplied, use this script to generate a FASTA file containing
# the appropriate unique sequences and their abundances for use in oligotyping

my $usage = "\n\tuniq_mapped_by_smpl.pl [-h -o <output PATH> -m <mapping TXT>] -i <input FASTA>\n\n";

# defaults 
my $help;
my $outDir = './';
my $mapFile;
my $inFile;

GetOptions (
	'help!' => \$help,
	'o=s'   => \$outDir,
	'm=s'   => \$mapFile,
	'i=s'   => \$inFile,
	) or die $usage;

die $usage unless $help or $inFile;
if ($outDir !~ /\/$/) {$outDir = "$outDir\/"}

if ($help) {help_txt()}
else {
	# "global" variables
	my ($fileName) = $inFile =~ /(.+)\.fasta/;

	if ($mapFile) {
		# "recreating" variables
		my $outFasta = "${outDir}${fileName}_by_smpl.fasta";
		my %uniq_seqs_by_id;
		my %smpl_read_ids;

		open INF, "<$inFile" or die "\n\tError: cannot open $inFile\n\n";
		while (<INF>) {
			if ($_ =~ /^\>/) {
				my ($uniq_id) = /^\>(\d+)\-/;
				my $uniq_seq = <INF>;
				chomp $uniq_seq;
				$uniq_seqs_by_id{$uniq_id} = $uniq_seq;
			}
		}
		close INF;

		open IMP, "<$mapFile" or die "\n\tError: cannot open $mapFile\n\n";
		open OFA, ">$outFasta" or die "\n\tError: cannot create $outFasta\n\n";
		while (<IMP>) {
			my ($uniq_id) = /^(\d+)\t/;
			my ($smpl_ct_string) = /\t(\S+)$/;
			my @smpl_cts = split(':', $smpl_ct_string);

			foreach my $smpl_ct (@smpl_cts) {
				my ($smpl, $count) = split('-', $smpl_ct);
				$smpl_read_ids{$smpl}++;
				# >Sample-Read_ID|freq:42|X|Y
				print OFA "\>Sample-${smpl}_Read$smpl_read_ids{$smpl}|freq:$count\n$uniq_seqs_by_id{$uniq_id}\n";
			}
		}
		close IMP; close OFA;
	}
	else {
		# "uniquing" variables
		my %seq_counts;
		my %smplseq_counts;
		my %smpls_by_seq;
		my $outFasta = "${outDir}${fileName}.uniq.fasta";
		my $outMap = "${outDir}${fileName}.uniq_map.txt";

		open INF, "<$inFile" or die "\n\tError: cannot open $inFile\n\n";
		while (<INF>) {
			if ($_ =~ /^\>/) {
				my ($smpl) = /^\>(\w+)\-\d/;
				my $seq = <INF>;
				chomp $seq;

				my $smplseq = "$smpl-$seq";

				$seq_counts{$seq}++;
				$smplseq_counts{$smplseq}++;
			}
		}
		close INF;

		my @smplseqs = sort keys %smplseq_counts;
		foreach my $smplseq (@smplseqs) {
			my ($smpl, $seq) = split('-', $smplseq);
			push @{$smpls_by_seq{$seq}}, $smpl;
		}

		my @uniq_seqs = sort {$seq_counts{$b} <=> $seq_counts{$a}} keys %seq_counts;
		open OFA, ">$outFasta" or die "\n\tError: cannot create $outFasta\n\n";
		open OMP, ">$outMap" or die "\n\tError: cannot create $outMap\n\n";

		my $uniq_id = 0;
		foreach my $uniq_seq (@uniq_seqs) {
			$uniq_id++;
			print OFA "\>$uniq_id-$seq_counts{$uniq_seq}\n$uniq_seq\n";

			my @smpls = @{$smpls_by_seq{$uniq_seq}};
			my @smplseqs = map {"$smpls[$_]-$uniq_seq"} 0..$#smpls;
			my @counts_in_smpl = @smplseq_counts{@smplseqs};
			my @smpls_w_counts = map {"$smpls[$_]-$counts_in_smpl[$_]"} 0..$#smpls;
			my $joined_smpls_w_counts = join(':', @smpls_w_counts);
			print OMP "$uniq_id\t$joined_smpls_w_counts\n";

		}
		close OFA;
	}
}

sub help_txt {
	print $usage;
}