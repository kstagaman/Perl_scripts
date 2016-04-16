#!/usr/bin/perl
# remove_rev_primer.pl
use strict; use warnings;

# for use in a directory containing order_amplicons.pl output files (or another script utilizing order_amplicons.pl)

die "usage: remove_rev_primer.pl <igm primer seqs file> <igz2 primer seqs file>" unless @ARGV == 2;

my @igm_rev_files = `ls *IgM*.rev.distinct.fa`;
chomp @igm_rev_files;
my $igmrevprimer;

open IGMPRIMER, "<$ARGV[0]";

while (<IGMPRIMER>) {
	if ($_ =~ />reverse/) {
		$_ = <IGMPRIMER>;
		($igmrevprimer) = $_;
	}
}
close IGMPRIMER;

chomp $igmrevprimer;
my $igmrevprimerseq = reverse $igmrevprimer;
$igmrevprimerseq =~ tr/ACGTURYKMBVDH/TGCAAYRMKVBHD/;

foreach my $igm_rev_file (@igm_rev_files) {
	my ($tag) = $igm_rev_file =~ /(\w+\.*\d*)\.rev/;
	open IN, "<$igm_rev_file" or die "Error: cannot open $igm_rev_file\n";
	open OUT, ">$tag.rev.distinct.noprimer.fa" or die "Error: cannot open $tag.rev.distinct.noprimer.fa\n";

	my $num_good_igm_seqs = 0;
	
	while (<IN>) {
		if ($_ =~ /^\>/){
			my ($id) = $_ =~ /^\>\d+:(.+):bp\d+:$/;
			$_ = <IN>;
			my ($seq) = $_ =~ /([ACGT]*)$igmrevprimerseq[ACGT]*$/;
			my $seqlength = length($seq);
			if ($seqlength >= 74) {
				$num_good_igm_seqs++;
				print OUT "\>$num_good_igm_seqs:$id:bp$seqlength:\n$seq\n";
			}
		}
	}
	close IN; close OUT;	
}

######

my @igz2_rev_files = `ls *IgZ2*.rev.distinct.fa`;
chomp @igz2_rev_files;
my $igz2revprimer;

open IGZ2PRIMER, "<$ARGV[1]";

while (<IGZ2PRIMER>) {
	if ($_ =~ />reverse/) {
		$_ = <IGZ2PRIMER>;
		($igz2revprimer) = $_;
	}
}
close IGZ2PRIMER;

chomp $igz2revprimer;
my $igz2revprimerseq = reverse $igz2revprimer;
$igz2revprimerseq =~ tr/ACGTURYKMBVDH/TGCAAYRMKVBHD/;

foreach my $igz2_rev_file (@igz2_rev_files) {
	my ($tag) = $igz2_rev_file =~ /(\w+\.*\d*)\.rev/;
	open IN, "<$igz2_rev_file" or die "Error: cannot open $igz2_rev_file\n";
	open OUT, ">$tag.rev.distinct.noprimer.fa" or die "Error: cannot create $tag.rev.distinct.noprimer.fa\n";
	
	my $num_good_igz2_seqs = 0;
	
	while (<IN>) {
		if ($_ =~ /^\>/){
			my ($id) = $_ =~ /^\>\d+:(.+):bp\d+:$/;
			$_ = <IN>;
			my ($seq) = $_ =~ /([ACGT]*)$igz2revprimerseq[ACGT]*$/;
			my $seqlength = length($seq);
			if ($seqlength >= 68) {
				$num_good_igz2_seqs++;
				print OUT "\>$num_good_igz2_seqs:$id:bp$seqlength:\n$seq\n";
			}
		}
	}
	close IN; close OUT;	
}
