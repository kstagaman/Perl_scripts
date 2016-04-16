#!/usr/bin/perl
# random_vdj.pl
use strict; use warnings;
use Getopt::Long;
use Math::GSL::RNG;
use Math::GSL::Randist;

my $usage = "\n\tUsage: random_seqs.pl [-h -o <output dir>] -n <number>\n\n";

# defaults
my $help;
my $outdir = './';
my $n;

GetOptions (
	'help!' => \$help,
	'o=s'   => \$outdir,
	'n=i'   => \$n,
	) or die $usage;

if ($outdir !~ /\/$/) {$outdir = "$outdir\/"}
die $usage unless $help or $n;

if ($help) {
	print $usage
	print "Use this script to generate a certain number of random VDJ combinations\n";
}
else {

# global
	my $Vfile = "/Users/keaton/Reference_sets/imgt.zf_ighv.fa";
	my $Dfile = "/Users/keaton/Reference_sets/imgt.zf_ighd-m.fa";
	my $Jfile = "/Users/keaton/Reference_sets/imgt.zf_ighj-m.fa";
	my @v_segs;
	my @d_segs;
	my @j_segs;
	my @seqs;
	my %seqAbunds;

# get canonical sequences
	open VIN, "<$Vfile" or die "\n\tError: cannot open $Vfile";
	while (<VIN>) {
		if ($_ !~ /^>/) {
			my $v_seg = $_;
			chomp $v_seg;
			push @v_segs, $v_seg;
		}
	}
	close VIN;

	open DIN, "<$Dfile" or die "\n\tError: cannot open $Dfile";
	while (<DIN>) {
		if ($_ !~ /^>/) {
			my $d_seg = $_;
			chomp $d_seg;
			push @d_segs, $d_seg;
		}
	}
	close DIN;

	open JIN, "<$Jfile" or die "\n\tError: cannot open $Jfile";
	while (<JIN>) {
		if ($_ !~ /^>/) {
			my $j_seg = $_;
			chomp $j_seg;
			push @j_segs, $j_seg;
		}
	}
	close JIN;

# generate random combos and count abundances
	for (my $i=0; $i < $n; $i++) {
		my $randV = $v_segs[rand @v_segs];
		my $randD = $d_segs[rand @d_segs];
		my $randJ = $j_segs[rand @j_segs];

		my $seq = "${randV}${randD}${randJ}";
		$seq = mutate($seq);
		$seqAbunds{$seq}++;
	}

# get sequences sorted by abundance
	@seqs = sort {$seqAbunds{$b} <=> $seqAbunds{$a}} keys %seqAbunds;

	open OUT, ">random_vdj_n${n}.txt" or die "\n\tError: cannot create random_vdj_n${n}.txt\n\n";
	print OUT "seq\tabund\n";

	foreach my $seq (@seqs) {
		print OUT "$seq\t$seqAbunds{$seq}\n";
	}
	close OUT;
}

sub mutate {
	my ($seq) = @_;
	my @nts = ('a', 'c', 'g', 't');
	my $num_mutations = int rand (0.01 * length $seq);

	for (my $m = 0; $m < $num_mutations; $m++) {	
		my $mutation_type = int rand 4;

		if ($mutation_type >= 2) {
			my ($nt) = $nts[int rand 4];
			my $sub_site = int rand length $seq;
			my @seq = split("", $seq);
			splice(@seq, $sub_site, 1, $nt);
			$seq = join("", @seq);
		}
			
		elsif ($mutation_type == 1) {
			my ($nt) = $nts[int rand 4];
			my $sub_site = int rand length $seq;
			my @seq = split("", $seq);
			splice(@seq, $sub_site, 0, $nt);
			$seq = join("", @seq);
		}
			
		elsif ($mutation_type == 0) {
			my $sub_site = int rand length $seq;
			my @seq = split("", $seq);
			splice(@seq, $sub_site, 1);
			$seq = join("", @seq);
		}
	}
	return $seq;
}