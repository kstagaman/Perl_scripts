#!/usr/bin/perl
# codonproj.pl
use strict; use warnings;

my @genome_segs = ();

open(IN, "<$ARGV[0]") or die "error reading $ARGV[0] for reading";

while(<IN>) {
	if ($_ =~ /\d+\s[acgt]{10}\s/) {
		$_ =~ s/\s//g;
		my ($genome_seg) = $_ =~ /([acgt]+)/;
		push(@genome_segs, $genome_seg);
	}
}

close IN;

my $genome = join("", @genome_segs);

my @comp_begs = ();
my @comp_ends = ();
my @begs = ();
my @ends = ();

open(IN, "<$ARGV[0]") or die "error reading $ARGV[0] for reading";

while(<IN>) {
	if ($_ =~ /^\s{5}CDS/) {
		if ($_ =~/complement\(/) {
			my ($comp_beg, $comp_end) = $_ =~ /(\d+)\.\.\>*(\d+)/;
			push(@comp_begs, $comp_beg);
			push(@comp_ends, $comp_end);
		} else {
			my ($beg, $end) = $_ =~ /(\d+)\.\.\>*(\d+)/;
			push(@begs, $beg);
			push(@ends, $end);
		}
	}
}

close IN;

my @cds = ();

for (my $i = 0; $i < @begs; $i++) {
	my $cd = substr($genome, $begs[$i] - 1, $ends[$i] - $begs[$i]);
	push(@cds, $cd);
}

my @revcomp_cds = ();

for (my $i = 0; $i < @comp_begs; $i++) {
	my $comp_cd = substr($genome, $comp_begs[$i] - 1, $comp_ends[$i] - $comp_begs[$i]);
	$comp_cd =~ tr/acgt/tgca/;
	my $revcomp_cd = reverse $comp_cd;
	push(@revcomp_cds, $revcomp_cd);
}

my @bothcdsgroups = ();
push(@bothcdsgroups, @cds);
push(@bothcdsgroups, @revcomp_cds);
my $allcds = join("", @bothcdsgroups);

my %count = ();
my $total = 0;

for (my $i = 0; $i < length($allcds)-2; $i += 3) {
	my $codon = substr($allcds, $i, 3);
	if (exists $count{$codon}) {$count{$codon}++}
	else					   {$count{$codon} = 1}
	$total ++;
}

print "\nCODON\tCOUNT\tFREQUENCY\n";

foreach my $codon (sort keys %count) {
	my $frequency = $count{$codon}/$total;
	printf "%s\t%d\t%.4f\n", $codon, $count{$codon}, $frequency;
}
