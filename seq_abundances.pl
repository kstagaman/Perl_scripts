#!/usr/bin/perl
# seq_abundances.pl
use strict; use warnings;

# use this script to find identical seqs and list their abundances

die "Usage: seq_abundances.pl" unless @ARGV == 0;

my @fwdfiles = `ls *fwd.fa`;
my @revfiles = `ls *rev.fa`;
chomp (@fwdfiles, @revfiles);


foreach my $fwdfile (@fwdfiles) {
	my ($fwd_tag) = $fwdfile =~ /(.+)\.fa$/;
	open IN, "<$fwdfile" or die "Error: cannot open $fwdfile";
	open OUT, ">$fwd_tag.distinct.fa" or die "Error: cannot create $fwd_tag.distinct.fa";
	my ($sampleID) = $fwdfile =~ /^(.+)\.fwd/;
	my %count = ();

	while (<IN>) {
		if ($_ =~ /^\>/) {
			$_ = <IN>;
			my ($seq) = $_;
			chomp $seq;
			$count{$seq}++;
		}
	}
	close IN;
	
	my @seqs = keys %count;
	my $i = 1;

	foreach my $seq (@seqs) {
		my $seqlength = length $seq;
		print OUT "\>$i:$sampleID:N$count{$seq}:bp$seqlength:\n$seq\n";
		$i++;
	}
	
	close IN; close OUT;
}

foreach my $revfile (@revfiles) {
	my ($rev_tag) = $revfile =~ /^(.+)\.fa$/;
	open IN, "<$revfile" or die "Error: cannot open $revfile";
	open OUT, ">$rev_tag.distinct.fa" or die "Error: cannot create $rev_tag.distinct.fals";
	my ($sampleID) = $revfile =~ /^(.+).rev/;
	my %count = ();

	while (<IN>) {
		if ($_ =~ /^\>/) {
			$_ = <IN>;
			my ($seq) = $_;
			chomp $seq;
			$count{$seq}++;
		}
	}
	close IN;
	
	my @seqs = keys %count;
	my $i = 1;

	foreach my $seq (@seqs) {
		my $seqlength = length $seq;
		print OUT "\>$i:$sampleID:N$count{$seq}:bp$seqlength:\n$seq\n";
		$i++;
	}
	
	close IN; close OUT;
}