#!/usr/bin/perl
# post-primer-pre-v_seqs.pl
use strict; use warnings;
use Getopt::Long;

# this script requires 2 inputs:
#     1: A FASTA file containing JOINED reads with the FORWARD PRIMER REMOVED
#     2: A TSV containing V-QUEST OUTPUT in the form of a SEQUENCE ID and the V-MATCHING SEQUENCE
# the script takes these two files and extracts the part of the sequence that didn't match to a V-region,
# but also wasn't a part of the primer


my $usage = "\n\tpost-primer-pre-v_seqs.pl [-h -o] -v <v-matching TXT> -f <primer-removed-joined FASTA>\n\n";

# defaults
my $help;
my $outdir = './';
my $vMatchFile;
my $fastaFile;

GetOptions (
	'help!' => \$help,
	'o=s'   => \$outdir,
	'v=s'   => \$vMatchFile,
	'f=s'   => \$fastaFile,
) or die $usage;

if ($outdir !~ /\/$/) {$outdir = "$outdir\/"}
die $usage unless $help or ($vMatchFile and $fastaFile);

if ($help) {
	print $usage;
	help_txt();
}
else {
	# global variables
	my %v_matches_by_id;
	my ($outname) = $fastaFile =~ /^(\S+)\.fa$/;

	open VMF, "<$vMatchFile" or die "\n\tError: cannot open $vMatchFile\n\n";
	$_ = <VMF>;
	$|++;
	print STDOUT "Collecting V-region matches... ";

	while (<VMF>) {
		my ($id) = /^(\S+):\w*\t/;
		# print "$id\n";
		my ($vseq) = /\t([ACGTN]+)$/i;
		# print "$vseq\n";
		$vseq = uc $vseq;
		$v_matches_by_id{$id} = $vseq;
	}
	close VMF;
	$|++;
	print STDOUT "done\n";

	# my @ids = keys %v_matches_by_id;
	# foreach my $id (@ids) {
	# 	my $length = length $v_matches_by_id{$id};
	# 	print "$id\t$v_matches_by_id{$id}\t$length\n";
	# }

	open FST, "<$fastaFile" or die "\n\tError: cannot open $fastaFile\n\n";
	my @preVseqs;
	$|++;
	print STDOUT "Collecting full sequences... ";

	# my $in_count = 0;
	# my $out_count = 0;

	while (<FST>) {
		if ($_ =~ /^\>/) {
			# $in_count++;
			my ($id) = /^\>(\S+:\d+):\w{0,4}:*p7/;
			# print "$id\n";
			my $seq = <FST>;
			chomp $seq;
			$seq = uc $seq;
			if (exists $v_matches_by_id{$id}) {
				# $out_count++;
				my ($preVseq) = $seq =~ /^([ACGTN]+)$v_matches_by_id{$id}/i;
				if ($preVseq) {
					push @preVseqs, $preVseq;
				}
			}
		}
	}
	close FST;
	$|++;
	print STDOUT "done\n";
	# print "in count: $in_count\n";
	# print "out count: $out_count\n";

	my %uniqPreVseqs;
	$|++;
	print STDOUT "Merging unique seqs... ";

	foreach my $preVseq (@preVseqs) {
		$uniqPreVseqs{$preVseq}++;
	}
	$|++;
	print STDOUT "done\n";

	my @uniqPreVseqs = keys %uniqPreVseqs;
	my %uniqPreVseqs_lens;
	$|++;
	print STDOUT "Calculating unique seq lengths... ";

	foreach my $uniqPreVseq (@uniqPreVseqs) {
		my $uniqPreVseq_len = length $uniqPreVseq;
		$uniqPreVseqs_lens{$uniqPreVseq} = $uniqPreVseq_len;
	}
	$|++;
	print STDOUT "done\n";

	my @orderedUniqPreVseqs = sort {$uniqPreVseqs_lens{$b} <=> $uniqPreVseqs_lens{$a}} keys %uniqPreVseqs_lens;
	my %mergedUniqPreVseqs;
	my %used_preVseqs;
	$|++;
	print STDOUT "Merging matching seqs... ";

	for (my $i = 0; $i < @orderedUniqPreVseqs-1; $i++) {
		my $frst_preVseq = $orderedUniqPreVseqs[$i];
		next if ($used_preVseqs{$frst_preVseq});
		$mergedUniqPreVseqs{$frst_preVseq} = $uniqPreVseqs{$frst_preVseq};

		for (my $j = $i+1; $j < @orderedUniqPreVseqs; $j++) {
			my $scnd_preVseq = $orderedUniqPreVseqs[$j];
			next if ($used_preVseqs{$scnd_preVseq});

			if ($frst_preVseq =~ /$scnd_preVseq/) {
				$mergedUniqPreVseqs{$frst_preVseq}++;
				$used_preVseqs{$scnd_preVseq}++;
			}
		}
	}
	$|++;
	print STDOUT "done\n";

	my @mergedUniqPreVseqs = sort {$mergedUniqPreVseqs{$b} <=> $mergedUniqPreVseqs{$a}} keys %mergedUniqPreVseqs;

	open OUT, ">${outdir}$outname.uniq_pre-v.fa" or die "\n\tError: cannot create ${outdir}$outname.uniq_pre-v.fa\n\n";
	my $uniq_count = 0;

	foreach my $mergedUniqPreVseq (@mergedUniqPreVseqs) {
		print OUT "\>$uniq_count:$mergedUniqPreVseqs{$mergedUniqPreVseq}\n$mergedUniqPreVseq\n";
		$uniq_count++;
	}
	close OUT;

}

sub help_txt {
	print "\t\t-h: the helpful help screen\n";
	print "\t\t-o: the output directory, default is current\n";
	print "\t\t-v: a TSV containing V-QUEST OUTPUT in the form of a SEQUENCE ID and the V-MATCHING SEQUENCE\n";
	print "\t\t-f: a FASTA file containing JOINED reads with the FORWARD PRIMER REMOVED\n\n";
}