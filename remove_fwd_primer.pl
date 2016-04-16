#!/usr/bin/perl
# remove_fwd_primer.pl
use strict; use warnings;

# for use in a directory containing order_amplicons.pl output files (or another script utilizing order_amplicons.pl)

die "usage: remove_fwd_primer.pl <primer seqs file>" unless @ARGV == 1;

my @fwd_files = `ls *.fwd.distinct.fa`;
chomp @fwd_files;
my $fwdprimer;

open SUM, ">remove_fwd_primer_summary.txt";
my $cum_gen_avg_length = 0;
my $avg_length_count = @fwd_files;

open PRIMER, "<$ARGV[0]";


while (<PRIMER>) {
	if ($_ =~ />forward/) {
		$_ = <PRIMER>;
		($fwdprimer) = $_;
	}
}
close PRIMER;

chomp $fwdprimer;

foreach my $fwd_file (@fwd_files) {
	my ($tag) = $fwd_file =~ /(\w+\.*\d*)\.fwd/;
	open IN, "<$fwd_file" or die "Error: cannot open $fwd_file\n";
	open OUT, ">$tag.fwd.distinct.noprimer.fa" or die "Error: cannot create $tag.fwd.distinct.noprimer.fa\n";
	my @lengths;
	my $totalcount = 0;

	my $num_good_seqs = 0;
	
	while (<IN>) {
		if ($_ =~ /^\>/){
			my ($id) = $_ =~ /^\>\d+:(.+):bp\d+:$/;
			$totalcount++;
			$_ = <IN>;	
			my ($seq) = $_ =~ /[ACGT]*$fwdprimer([ACGT]*)/;
			my $seqlength = length($seq);
			push(@lengths, $seqlength);
			if ($seqlength >= 64) {
				$num_good_seqs++;
				print OUT "\>$num_good_seqs:$id:bp$seqlength:\n$seq\n";
				
			}
		}
	}
	close IN; close OUT;
	
	my $zerocount = 0;
	my $cumlengths = 0;
	my $remseqs = 0;

	foreach my $length (@lengths) {
		if ($length == 0) {
			$zerocount++;
		}
		else {
			$cumlengths += $length;
			$remseqs++;
		}
	}
	my $percentzeros = ($zerocount / $totalcount);
	my $avglength = $cumlengths / $remseqs;
	$cum_gen_avg_length += $avglength;
	my $percentrems = ($remseqs / $totalcount);

	printf SUM "Out of %d seqs in %s\:\n\t seqs removed\: %d \(%.3f\)\n\t remaining seqs\: %d \(%.3f\)\n\t avg length of seqs\: %.2f nts\n\n", $totalcount, $fwd_file, $zerocount, $percentzeros, $remseqs, $percentrems, $avglength;
	print "$tag\n";
	
}

my $gen_avg_length = $cum_gen_avg_length / $avg_length_count;
printf SUM "Average seq length for all files is %.2f nts\n", $gen_avg_length;

close SUM;
