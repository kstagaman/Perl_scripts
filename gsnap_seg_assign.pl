#!/usr/bin/perl
# gsnap_seg_assign.pl
use strict; use warnings;
use Getopt::Long;

# get from SAM
	# id
	# start pos
	# sign on template length
	# template length
	# if sign on template is neg, switch start and end pos
	# mates

# compare above to igh_genomic_positions_tsv.txt
# output to fwd and rev fastasfor classify seqs and bowtie confirmation, and primer matching

my $usage = "\n\tgsnap_seg_assign.pl [options: -h -q -o <PATH to output dir> -mq <N> -lt <N> -c <N>] -i <SAM file> -p <genomic positions TSV>\n\n";

# defaults
my $help;
my $quiet;
my $outdir = './';
my $qual_thresh = 0;
my $len_thresh = 0;
my $chromosome = 3;
my $infile;
my $positions;


GetOptions(
	'help!'  => \$help,
	'quiet!' => \$quiet,
	'o=s'    => \$outdir,
	'i=s'    => \$infile,
	'p=s'    => \$positions,
) or die $usage;

die $usage unless $infile and $positions or $help;
if ($outdir !~ /\/$/) {$outdir = "$outdir\/"}

if ($help) {help_text()}
else {
	# "global" variables
	my %geneByStart;
	my @starts;
	my ($filename) = $infile   =~ /^(\S+)\.sam$/;
	# my ($sample)   = $filename =~ /^([mz][abcd]\d{2})/;
	my $sample = $filename;

	open POS, "<$positions" or die "\n\tError: cannot open $positions\n\n";
	$_ = <POS>;
	while (<POS>) {
		my ($gene)  = /^(\S+)\t/;
		my ($label) = /^$gene\t(\S+)\t/;
		my ($chr)   = /^$gene\t$label\t(\d{1,2})\t/;
		my ($start) = /\t(\d+)\t\d+$/;
		my ($end)   = /\t(\d+)$/;
		
		$geneByStart{$start} = {gene => $gene, label => $label, chrm => $chr, end => $end};
		push @starts, $start;
	}
	close POS;

	open SAM, "<$infile" or die "\n\tError: cannot open $infile\n\n";
	open FWD, ">${outdir}$filename.vsegs.fa" or die "\n\tError: cannot create ${outdir}$filename.vsegs.fa\n\n";
	open REV, ">${outdir}$filename.jcsegs.fa" or die "\n\tError: cannot create ${outdir}$filename.jcsegs.fa\n\n";
	open TSV, ">${outdir}$filename.seg_assign_stats_tsv.txt" or die "\n\tError: cannot create ${outdir}$filename.seg_assign_stats_tsv.txt\n\n";
	print TSV "sample\tseq.id\tstart.pos\tgene\tlabel\n";

	my $read_counts;
	my $match_counts;

	while (<SAM>) {

		if ($_ !~ /^@/) {
			my ($seq_id)     = /^(\w+)\t/;
			my ($chr)        = /^$seq_id\t\d+\t([\w\*]+)\t/;
			my ($read_start) = /^$seq_id\t\d+\t[\w\*]+\t(\d+)\t/;
			my ($map_qual)   = /^$seq_id\t\d+\t[\w\*]+\t$read_start\t([\d\*]+)\t/;
			my ($length)     = /^$seq_id\t\d+\t[\w\*]+\t$read_start\t[\d\*]+\t\w+\t\S+\t\d+\t\-*(\d+)\t/;
			# print "$chr\t$read_start\t$map_qual\n";
			my ($seq)        = /^$seq_id\t\d+\t[\w\*]+\t$read_start\t[\d\*]+\t\w+\t\S+\t\d+\t\-*\d+\t([ACGT]+)\t/;
			my $len_sign = '+';
			
			if ($_ =~ /^$seq_id\t\d+\t\d{1,2}\t\d+\t\d+\t\w+\t\S\t\d+\t\-\d/) {
				$len_sign = '-';
			}
			
			if ($chr eq "$chromosome" and $map_qual >= $qual_thresh and $length >= $len_thresh) {

				foreach my $start (@starts) {

					if ($read_start >= $start and $read_start <= $geneByStart{$start}->{end}) {
						print TSV "$sample\t$seq_id\t$read_start\t$geneByStart{$start}->{gene}\t$geneByStart{$start}->{label}\n";
						$match_counts++;

						if ($len_sign eq '+') {
							print REV "\>$sample:$seq_id:$geneByStart{$start}->{gene}\n$seq\n";
						} else {
							print FWD "\>$sample:$seq_id:$geneByStart{$start}->{gene}\n$seq\n";
						}
					}
				}
			}
		}
		$read_counts++;
	}
	close SAM; close FWD; close REV; close TSV;
	print "$sample:\n\t$read_counts reads analyzed\n\t$match_counts matches made\n" unless $quiet;
}







sub help_text{
	print $usage;
	print "\t\t-h: this helpful help screen\n";
	print "\t\t-q: suppress output to STDOUT\n";
	print "\t\t-o: directory to write output files to, default working directory\n";
	print "\t\t-mq: minimum mapping quality required to write sequence, default = 0\n";
	print "\t\t-lt: minimum template length required to write sequence, default = 0\n";
	print "\t\t-c: chromosome with sequences of interest, default 3 (because IgH)\n";
	print "\t\t-i: input SAM file\n";
	print "\t\t-p: reference TSV file containing genomic positions of sequences of interest\n\n";
}