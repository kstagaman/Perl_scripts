#!/usr/bin/perl
# get_gene-flanking_seqs.pl
use strict; use warnings;
use Getopt::Long;

my $usage = "\n\tget_gene-flanking_seqs.pl [-h -o -n <num flanking bps>] -m <gene matching string> -i <GENBANK file>\n\n";

# defaults
my $help;
my $outdir = './';
my $flanking = 10;
my $gene_string;
my $infile;

GetOptions (
	'help!' => \$help,
	'o=s'   => \$outdir,
	'n=i'   => \$flanking,
	'm=s'   => \$gene_string,
	'i=s'   => \$infile,
) or die $usage;

die $usage unless $help or ($gene_string and $infile);
die "\n\tThe number of flanking bps much be greater than 0\n\n" if ($flanking < 1);
if ($outdir !~ /\/$/) {$outdir = "$outdir\/"}

if ($help) {help_txt()}
else{
	# global variables
	my ($filename) = $infile =~ /\/*([\w\s]+)\.txt$/;
	my $region_strt;
	my %gene_strt_stop;
	my @genes;
	my @seq_lines;
	my $seq;

	open INF, "<$infile" or die "\n\tError: cannot open $infile\n\t";
	while (<INF>) {
		if ($_ =~ /^ACCESSION\s+/) {
			# print "$_";
			($region_strt) = /ACCESSION\s+\w+:\w+:\d+:(\d+):\d+:\d+/;
			# print "$region_strt\n";
		}

		if ($_ =~ /^\s+gene\s+complement/) {
			my ($gene_strt) = $_ =~ /complement\((\d+)\.\./;
			$gene_strt = $gene_strt - 1;
			# print "$gene_strt\n";
			my ($gene_stop) = $_  =~ /\.\.(\d+)\)/;
			my $gene;
			until ($_ =~ /\/locus_tag=/) {
				$_ = <INF>;
				($gene) = $_ =~ /\/locus_tag=\"(.+)\"/;
			}
			# print "$gene\n";

			if ($gene =~ /$gene_string/) {
				# print "$gene\n";
				$gene_strt_stop{$gene} = {strt => $gene_strt, stop => $gene_stop};
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
	close INF;

	# print "@seq_lines\n";
	$seq = join("", @seq_lines);
	# print "$seq\n";

	@genes = sort {$a cmp $b} keys %gene_strt_stop;

	open GNS, ">${outdir}$filename.${gene_string}_seqs_w_pos.fa" or die "\n\tError: cannot create ${outdir}$filename.${gene_string}_seqs_w_pos.fa\n\n";
	open BFR, ">${outdir}$filename.${flanking}bp_before_${gene_string}.fa" or die "\n\tError: cannot create ${outdir}$filename.${flanking}bp_before_${gene_string}.fa\n\n";
	open AFT, ">${outdir}$filename.${flanking}bp_after_${gene_string}.fa" or die "\n\tError: cannot create ${outdir}$filename.${flanking}bp_after_${gene_string}.fa\n\n";

	foreach my $gene (@genes) {
		my $genomic_strt = $gene_strt_stop{$gene}->{strt} + $region_strt;
		my $genomic_stop = $gene_strt_stop{$gene}->{stop} + $region_strt;

		my $before_strt = $gene_strt_stop{$gene}->{strt} - $flanking;
		my $gene_length = $gene_strt_stop{$gene}->{stop} - $gene_strt_stop{$gene}->{strt};

		my $gene_seq = substr($seq, $gene_strt_stop{$gene}->{strt}, $gene_length);
		my $before_flank = substr($seq, $before_strt, $flanking);
		my $after_flank = substr ($seq, $gene_strt_stop{$gene}->{stop}, $flanking);

		print GNS "\>$gene:$genomic_strt-$genomic_stop\n$gene_seq\n";
		print BFR "\>$gene:${flanking}_bp_before\n$before_flank\n";
		print AFT "\>$gene:${flanking}_bp_after\n$after_flank\n";
	}

	close GNS; close BFR; close AFT;
}

sub help_txt {
	print $usage;
	print "\t\t-h: this helpful help screen\n";
	print "\t\t-o: output directory, default is current (./)\n";
	print "\t\t-n: number of base pairs to grab from either side of each gene, default = 10\n";
	print "\t\t-m: the string used to match genes of interest\n";
	print "\t\t-i: the input file in GENBANK flat file format\n\n";
}

