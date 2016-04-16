#!/usr/bin/perl
# remove_primers.pl
use strict; use warnings;
use Getopt::Long; use String::Approx 'amatch';

# Use this script to remove primers (and any unwanted preceding/trailing nts) from *joined* paired-end reads
# This script requires FASTA input

my $usage = "\n\tremove_primers.pl [-h -k -o <output PATH> -n <number nts> -m <number mismatches] -p <barcodes TXT> -i <input FASTA>\n\n";

# defaults
my $help;
my $keep;
my $outdir = './';
my $num_nts = 4;
my $prmrfile;
my $infile;
my $mismtchs = 1;

GetOptions (
	'help!' => \$help,
	'keep!' => \$keep,
	'o=s'   => \$outdir,
	'n=i'   => \$num_nts,
	'm=i'   => \$mismtchs,
	'p=s'   => \$prmrfile,
	'i=s'   => \$infile,
) or die $usage;

die $usage unless $help or ($infile and $prmrfile);

if ($outdir !~ /\/$/) {$outdir = "$outdir\/"}

if ($help) {
	print $usage;
	print_help_txt();
}
else {
	# global variables;
	my ($filename) = $infile =~ /^(\S+)\.fa$/;
	my @prmr_ct;
	my $fwd_prmr;
	my $fwd_len;
	my $rev_prmr;
	my $rev_len;
	my $in_seq_ct = 0;
	my $out_seq_ct = 0;

	open PMR, "<$prmrfile" or die "\n\tError: cannot open $prmrfile\n\n";

	while (<PMR>) {
		if (@prmr_ct > 2) {die "\n\tError: the script can only handle 2 primers (1 fwd, 1 rev) at once\n\n"}
		my ($name) = /^(\w+)\t/;
		next if (!$name);
		my ($prmr_seq) = /\t([ACGT]+)$/;
		if ($name =~ m/fo*r*w*a*r*d*/i) {
			$fwd_prmr = $prmr_seq;
			$fwd_len = length $prmr_seq;
			push @prmr_ct, $name;
		}
		elsif ($name =~ m/re*v*e*r*s*e/i)  {
			$rev_prmr = $prmr_seq;
			$rev_len = length $prmr_seq;
			push @prmr_ct, $name;
		}
		else {die "\n\tError: Primer names require fwd/forward and rev/reverse to be recongnized\n\n"}
	}
	close PMR;
	if (@prmr_ct < 2) {die "\n\tError: the script requires 2 primers (1 fwd, 1 rev) to work\n\n"}

	open INF, "<$infile" or die "\n\tError: cannot open $infile\n\n";
	open OUT, ">${outdir}$filename.no_primers.fa" or die "\n\tError: cannot create ${outdir}$filename.no_primers.fa\n\n";

	LINE: while (<INF>) {
		if ($_ =~ /^\>/) {
			$in_seq_ct++;
			my $hdr = $_;
			my $seq = <INF>;
			chomp $hdr;
			chomp $seq;
			my $seq_len = length $seq;
			my @fwd_subseqs;
			my %fwd_indices;
			my @rev_subseqs;
			my %rev_indices;

			for (my $i=0; $i < $num_nts; $i++) {
				my $rev_index = $seq_len - $rev_len - $i;
				my $fwd_subseq = substr($seq, $i, $fwd_len);
				my $rev_subseq = substr($seq, $rev_index, $rev_len);
				push @fwd_subseqs, $fwd_subseq;
				$fwd_indices{$fwd_subseq} = $i;
				push @rev_subseqs, $rev_subseq;
				$rev_indices{$rev_subseq} = $i;
			}

			my ($fwd_match) = amatch($fwd_prmr, ["i", "S$mismtchs", "D0"], @fwd_subseqs);
			# print "fwd_match: $fwd_match\n";
			my ($rev_match) = amatch($rev_prmr, ["i", "S$mismtchs", "D0"], @rev_subseqs);
			# print "rev_match: $rev_match\n";

			if (!$fwd_match or !$rev_match) {next LINE}

			my $new_seq_index = $fwd_len + $fwd_indices{$fwd_match};
			my $new_seq_len = $seq_len - ($rev_len + $rev_indices{$rev_match} + $fwd_len + $fwd_indices{$fwd_match});
			my $new_seq = substr($seq, $new_seq_index, $new_seq_len);

			print OUT "$hdr\n$new_seq\n";
			$out_seq_ct++;
		}
	}
	close INF; close OUT;

	open STA, ">${outdir}$filename.no_primers.stats.txt" or die "\n\tError: cannot create ${outdir}$filename.no_primers.stats.txt\n\n";
	print STA "Num seqs  input:\t$in_seq_ct\n";
	print STA "Num seqs output:\t$out_seq_ct\n";
	close STA;

	print "\n\tNum seqs  input:\t$in_seq_ct\n";
	print   "\tNum seqs output:\t$out_seq_ct\n\n";
}

sub print_help_txt {
	print "\t\t-h: this helpful help screen\n";
	print "\t\t-k: keep primers in sequence (but still discard preceding/trailing nts\n";
	print "\t\t-o: output directory, default is current\n";
	print "\t\t-n: max number of nts from ends to looks for primers\n";
	print "\t\t-m: max number of mismatches from primer sequence allowed\n";
	print "\t\t-p: file containing forward and reverse primers, see below for format\n";
	print "\t\t-i: input FASTA file\n\n";

	print "\t\tThe barcode file should be in the following format:\n";
	print "\t\t\tfwd\tNNNNNNNNNNNNNNNNNNNNN\n";
	print "\t\t\trev\tNNNNNNNNNNNNNNNNNNNNN\n";
}