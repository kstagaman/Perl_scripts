#!/usr/bin/perl
# recombine_igh.pl
use strict; use warnings;
use Getopt::Long;

# use this script to simulate recombining the IgH locus as outputting those sequences along with stats about lengths

my $usage = "\n\trecombine_igh.pl [-h -o -g -r -f]\n\n";

# defaults

my $help;
my $outdir = './';
my $genbank = '/Users/keaton/Documents/UO/IgH_intron_analysis/ighm_to_ighv_loci.txt';
my $rev_primer = 'AGCTATTGAAATTAATCCTTTTTAAAAGTCTT';
my $fwd_primer_revcomp = 'TTAAGTCAGGAAATTGACCTCATATGAGATGCAG';



GetOptions (
	'help!' => \$help,
	'g=s'   => \$genbank,
	'o=s'   => \$outdir,
	'r=s'   => \$rev_primer,
	'f=s'   => \$fwd_primer_revcomp,
	) or die $usage;

if ($outdir !~ /\/$/) {$outdir = "$outdir\/"}

if ($help) {help_txt()}
else {
	# global variables
	my $seqsout = "${outdir}recombined_igh_loci.fa";
	my $statout = "${outdir}recombined_igh_loci_stats.txt";
	my (%vsegs_strt_stop, %jsegs_strt_stop, %dsegs_strt_stop);
	my (@vsegs, @dsegs, @jsegs);
	my @seq_lines;
	my $seq;
	# my $rev_primer_len = length $rev_primer;


	open GEN, "<$genbank" or die "\n\tError: cannot open $genbank\n\n";
	while (<GEN>) {

		if ($_ =~ /^\s+gene\s+complement/) {
			my ($gene_strt) = $_ =~ /complement\((\d+)\.\./;
			$gene_strt = $gene_strt - 1;
			# print "$gene_strt\n";
			my ($gene_stop) = $_  =~ /\.\.(\d+)\)/;
			my $gene;

			until ($_ =~ /\/locus_tag=/) {
				$_ = <GEN>;
				($gene) = $_ =~ /\/locus_tag=\"(.+)\"/;
			}

			if ($gene =~ /ighv/) {
				# print "$gene\n";
				$vsegs_strt_stop{$gene} = {strt => $gene_strt, stop => $gene_stop};
			}
			elsif ($gene =~ /ighd2/) {
				$dsegs_strt_stop{$gene} = {strt => $gene_strt, stop => $gene_stop};
			}
			elsif ($gene =~ /ighj2/) {
				$jsegs_strt_stop{$gene} = {strt => $gene_strt, stop => $gene_stop};
			}
		}

		if ($_ =~ /^\s+\d+\s[ACGTN]/) {
			my ($seq_line) = $_ =~ /\d+\s([ACGTN]+\s*[ACGTN]*\s*[ACGTN]*\s*[ACGTN]*\s*[ACGTN]*\s*[ACGTN]*)\s/;
			# print "$seq_line\n";
			# $seq_line =~ s/\n//g;
			$seq_line =~ s/ //g;
			# print "$seq_line";
			push @seq_lines, $seq_line;
		}
	}
	close GEN;

	$seq = join ('', @seq_lines);
	$seq = uc $seq;
	my ($pre_rev_primer) = $seq =~ /^([ACGT]+)$rev_primer/;
	my $rev_primer_strt = length $pre_rev_primer;
	# my $pulled_rev_primer = substr ($seq, $rev_primer_strt, $rev_primer_len);
	# print "$pulled_rev_primer\n";

	@vsegs = sort {$a cmp $b} keys %vsegs_strt_stop;
	@dsegs = sort {$a cmp $b} keys %dsegs_strt_stop;
	@jsegs = sort {$a cmp $b} keys %jsegs_strt_stop;

	open SEQ, ">$seqsout" or die "\n\tError: cannot create $seqsout\n\n";
	open STA, ">$statout" or die "\n\tError: cannot create $statout\n\n";
	print STA "recombination\tlength\n";

	foreach my $vseg (@vsegs) {
		foreach my $dseg (@dsegs) {
			foreach my $jseg (@jsegs) {
				my $c2j_len = $jsegs_strt_stop{$jseg}->{strt} - $rev_primer_strt;
				my $j_len = $jsegs_strt_stop{$jseg}->{stop} - $jsegs_strt_stop{$jseg}->{strt};
				my $d_len = $dsegs_strt_stop{$dseg}->{stop} - $dsegs_strt_stop{$dseg}->{strt};
				my $v_len = $vsegs_strt_stop{$vseg}->{stop} - $vsegs_strt_stop{$vseg}->{strt};

				my $c2j   = substr($seq, $rev_primer_strt, $c2j_len);
				my $jseq  = substr($seq, $jsegs_strt_stop{$jseg}->{strt}, $j_len);
				my $dseq  = substr($seq, $dsegs_strt_stop{$dseg}->{strt}, $d_len);
				my $vseq  = substr($seq, $vsegs_strt_stop{$vseg}->{strt}, $v_len);
				my $v2end = substr($seq, $vsegs_strt_stop{$vseg}->{stop});
				my ($v2f) = $v2end =~ /^([ACGT]+$fwd_primer_revcomp)/;
				# print "$c2j\n\n";
				# print "$dseq\n\n";
				# print "$v2end\n\n";
				# print "$v2f\n\n";

				$jseq = lc $jseq;
				$dseq = lc $dseq;
				$vseq = lc $vseq;

				my $recombination = "${c2j}${jseq}${dseq}${vseq}${v2f}";
				# print "$recombination\n\n";
				my $recomb_len = length $recombination;
				# print "$recomb_len\n";

				print SEQ "\>$vseg:$dseg:$jseg:${recomb_len}bp\n$recombination\n";
				print STA "$vseg:$dseg:$jseg\t${recomb_len}\n";
			}
		}
	}
	close SEQ; close STA;
}


sub help_txt {
	print $usage;
	print "\t\t-h: this helpful help screen\n";
	print "\t\t-q: suppress any output to STDOUT\n";
	print "\t\t-o: the output directory, the default is current (./)\n";
	print "\t\t-g: the genbank file containing the igh locus information, default is \'/Users/keaton/Documents/UO/ighm_to_ighv_loci.txt\'\n";
	print "\t\t-r: reverse primer sequence to be used, default is \'CTGGGGCGCAGATGGTTGAG\'\n";
	print "\t\t-f: reverse-complement of the forward primer sequence to be used, default is \'TTAAGTCAGGAAATTGACCTCATATGAGATGCAG\'\n";
}