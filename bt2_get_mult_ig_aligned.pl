#!/usr/bin/perl
# bt2_get_mult_ig_aligned.pl
use strict; use warnings;
use Getopt::Long;

# use this script to get ig matched seqs after running bowtie
# make sure sample ID is unique to working directory and ensembl ids directory
# this script must be run in the same directory as the aligned FASTQ and SAM files

my $usage = "\n\tbt2_get_mult_ig_aligned.pl [options: -h] -s <sample ID> -e <ensembl ids CSV>\n\n";

# defaults
my $help;
my $paired;
my $unpaired;
my $sample;
my $ensembl_file;

GetOptions (
	'help!'    => \$help,
	'paired!'  => \$paired,
	'unpaired' => \$unpaired,
	's=s'      => \$sample,
	'e=s'      => \$ensembl_file,
) or die $usage;

die $usage unless $sample or $help;

if ($help) {
	help_text();
}
else {

	my ($sam1) = glob "$sample.fq_1.ig_mult*.sam";
	my ($sam2) = glob "$sample.fq_2.ig_mult*.sam";
	my ($samr)g = glob "$sample.rem.fq.ig_mult*.sam";

	open EIDS, "<$ensembl_file" or die "\n\tError: cannot open $ensembl_file\n\n";
	my %ensembl_ids;
	$_ = <EIDS>;
	
	while (<EIDS>) {
		my ($trans_id)   = /,(ENSDART\d+),/;
		my ($trans_name) = /,$trans_id,(.+),/;
		$ensembl_ids{$trans_id} = $trans_name;
	}

	close EIDS;

	open SAM1, "<$sam1" or die "\n\tError: cannot open $sam1\n\n";
	open SAM2, "<$sam2" or die "\n\tError: cannot open $sam2\n\n";
	open SAMR, "<$samr" or die "\n\tError: cannot open $samr\n\n";
	my (%sam1_ids, %sam2_ids, %samr_ids);
	my (%sam1_quals, %sam2_quals, %samr_quals);

	while (<SAM1>) {

		if ($_ !~ /^@/) {
			my ($seq_id)   = /^(\w+)\t/;
			my ($trans_id) = /$seq_id\t\d+\t(ENSDART\d+)\t/;
			my ($quality)  = /$seq_id\t\d+\t$trans_id\t\d+\t(\d+)\t/;

			if ($sam1_ids{$seq_id}) {
				push @{$sam1_ids{$seq_id}}, $trans_id;
			} else {
				$sam1_ids{$seq_id} = [$trans_id];
			}

			if ($sam1_quals{$seq_id}) {
				push @{$sam1_quals{$seq_id}}, $quality;
			} else {
				$sam1_quals{$seq_id} = [$quality];
			}
			
		}
	}

	while (<SAM2>) {

		if ($_ !~ /^@/) {
			my ($seq_id)   = /^(\w+)\t/;
			my ($trans_id) = /$seq_id\t\d+\t(ENSDART\d+)\t/;
			my ($quality)  = /$seq_id\t\d+\t$trans_id\t\d+\t(\d+)\t/;
			# print "$quality\n";

			if ($sam2_ids{$seq_id}) {
				push @{$sam2_ids{$seq_id}}, $trans_id;
			} else {
				$sam2_quals{$seq_id} = [$trans_id];
			}

			if ($sam2_quals{$seq_id}) {
				push @{$sam2_quals{$seq_id}}, $quality;
			} else {
				$sam2_quals{$seq_id} = [$quality];
			}
		}
	}

	while (<SAMR>) {

		if ($_ !~ /^@/) {
			my ($seq_id)   = /^(\w+)\t/;
			my ($trans_id) = /$seq_id\t\d+\t(ENSDART\d+)\t/;
			my ($quality)  = /$seq_id\t\d+\t$trans_id\t\d+\t(\d+)\t/;

			if ($samr_ids{$seq_id}) {
				push @{$samr_ids{$seq_id}}, $trans_id;
			} else {
				$samr_ids{$seq_id} = [$trans_id];
			}

			if ($samr_quals{$seq_id}) {
				push @{$samr_quals{$seq_id}}, $quality;
			} else {
				$samr_quals{$seq_id} = [$quality];
			}
		}
	}

	close SAM1; close SAM2; close SAMR;

	open CSV, ">$sample\_bt2_mult_align_stats.csv" or die "\n\tError: cannot create $sample\_bt2_mult_align_stats.csv\n\n";
	print CSV "sample,seq.id,match1,qual1,match2,qual2,match3,qual3,match4,qual4,match5,qual5,match6,qual6\n";

	my @sam1_keys = keys %sam1_ids;
	my @sam2_keys = keys %sam2_ids;
	my @samr_keys = keys %samr_ids;

	foreach my $key (@sam1_keys) {
		print CSV "$sample,$key,";
		my $len = @{$sam1_ids{$key}};
		
		for (my $i=0; $i < $len; $i++) {
			if ($sam1_ids{$key}[$i]) {
				print CSV "$ensembl_ids{$sam1_ids{$key}[$i]},$sam1_quals{$key}[$i]" unless !$ensembl_ids{$sam1_ids{$key}[$i]};
				# print "$sam1_ids{$key}[$i]\n";
			}
			print CSV ","  unless $i == ($len - 1);
			print CSV "\n" unless $i < ($len - 1);
		}
	}

	foreach my $key (@sam2_keys) {
		print CSV "$sample,$key,";
		my $len = @{$sam2_ids{$key}};
		
		for (my $i=0; $i < $len; $i++) {
			if ($sam2_ids{$key}[$i]) {
				print CSV "$ensembl_ids{$sam2_ids{$key}[$i]},$sam2_quals{$key}[$i]" unless !$ensembl_ids{$sam2_ids{$key}[$i]};
			}
			print CSV ","  unless $i == ($len - 1);
			print CSV "\n" unless $i < ($len - 1);
		}
	}

	foreach my $key (@samr_keys) {
		print CSV "$sample,$key,";
		my $len = @{$samr_ids{$key}};
		
		for (my $i=0; $i < $len; $i++) {
			if ($samr_ids{$key}[$i]) {
				print CSV "$ensembl_ids{$samr_ids{$key}[$i]},$samr_quals{$key}[$i]" unless !$ensembl_ids{$samr_ids{$key}[$i]};
			}
			print CSV ","  unless $i == ($len - 1);
			print CSV "\n" unless $i < ($len - 1);
		}
	}

	close CSV;
} 







sub help_text {
	print $usage;
	print "\t\t-h: this helpful help screen\n";
	print "\t\t-p: FASTQ files are result of paired-end bowtie2 alignment\n";
	print "\t\t-u: FASTQ files are result of single-end bowtie2 alignment\n";
	print "\t\t-s: unique sample ID to select appropriate files that go togther (e.g. ma26, zc30)\n";
	print "\t\t-e: CSV file containing Ensembl transcript IDS and their names\n\n"
}