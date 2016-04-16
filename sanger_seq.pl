#!/usr/bin/perl
# sanger_seq.pl
use strict; use warnings;

# run this script in the same directory as your sanger sequence files.

die "Usage: sanger_seq.pl <primers file>\n" unless @ARGV == 1;

my @files = `ls *.seq\ copy`;
chomp @files;
# print "@files\n";
my %primers;

open PRS, "<$ARGV[0]" or die "Error: cannot open $ARGV[0]\n";
while (<PRS>) {
	if ($_ =~ /^\>/) {
		my ($primer_name) = $_;
		chomp $primer_name;
		$_ = <PRS>;
		my ($primer_seq) = $_;
		chomp $primer_seq;
		$primers{$primer_seq} = $primer_name;
	}
}

close PRS;

my @primer_seqs = keys %primers;

open ALLFA, ">all_sanger_seqs.fa" or die "Error: cannot create all_sanger_seqs.fa\n";
open ONEFA, ">plate1_sanger_seqs.fa" or die "Error: cannot create plate1_sanger_seqs.fa\n";
open TWOFA, ">plate2_sanger_seqs.fa" or die "Error: cannot create plate2_sanger_seqs.fa\n";
open THREEFA, ">plate3_sanger_seqs.fa" or die "Error: cannot create plate3_sanger_seqs.fa\n";
open FOURFA, ">plate4_sanger_seqs.fa" or die "Error: cannot create plate4_sanger_seqs.fa\n";

		
foreach my $file (@files) {
	my ($seq_id) = $file =~ /^(\w+).T7/;
	my ($seq);
	my @partial_seqs;
	
	open SEQ, "<$file" or die "Error: cannot open $file\n";
	
	while (<SEQ>) {
		last if ($_ =~ /^\W/);
		my ($partial_seq) = $_;
		chomp $partial_seq;
		# print "$seq_id: $partial_seq\n";
		push @partial_seqs, $partial_seq;
	}
	
	close SEQ;
	
	($seq) = join "", @partial_seqs;
	
	
	print ALLFA "\>$seq_id\n$seq\n";
	
	if    ($seq_id =~ /1/) {print ONEFA ">$seq_id\n$seq\n"}
	elsif ($seq_id =~ /2/) {print TWOFA ">$seq_id\n$seq\n"}
	elsif ($seq_id =~ /3/) {print THREEFA ">$seq_id\n$seq\n"}
	elsif ($seq_id =~ /4/) {print FOURFA ">$seq_id\n$seq\n"}

	foreach my $primer_seq (@primer_seqs) {
		if ($seq =~ /$primer_seq/) {
			print "$seq_id\t$primers{$primer_seq}\n";
		}
	}
}

close ALLFA; close ONEFA; close TWOFA; close THREEFA; close FOURFA;