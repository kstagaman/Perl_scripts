#!/usr/bin/perl
# merge_seqs.pl
use strict; use warnings;

## Use this script to take fasta files, and merge identical sequences as well as those sequences that are subsets of those sequences.
## This script is written to handle one file at a time.  To run on multiple files, in the terminal, type: for file in <regex> ; do merge_seqs.pl $file ; done

die "Usage: merge_seqs.pl <fasta file>\n" unless @ARGV == 1;

my ($filename) = $ARGV[0] =~ /(.+)\.[fa|fasta]/;
open IN, "<$ARGV[0]" or die "Error: cannot open $ARGV[0]\n";
open OUT, ">$filename.merged.fa" or die "Error: cannot create $filename.merged.fa\n";
open ABN, ">$filename.abundances" or die "Error: cannot create $filename.abundances\n";

my %uniq_count;

while (<IN>) {           # merge identical sequences and count their abundances in a hash
	if ($_ !~ /^\>/) {
		my ($seq) = $_;
		chomp $seq;
		$uniq_count{$seq}++;
	}
}

close IN;

my @uniq_seqs = sort {length($b) <=> length($a)} keys %uniq_count; # sort seqs long to short

# print "\n";
# foreach my $uniq_seq (@uniq_seqs) {
#	my $length = length($uniq_seq);
#	print "$uniq_count{$uniq_seq}\t$length\t$uniq_seq\n";
# }
# print "\n";

my %final_count;

# print "\nN\tlen\ti\tj\tseq\n";

for (my $i = 0; $i < @uniq_seqs; $i++) {
	
	next if $uniq_seqs[$i] eq "KDS"; ## skip this loop if seq has been used (i.e. replaced with KDS)
	## create a hash that has initial abundances, starting with longest seqs
	$final_count{$uniq_seqs[$i]} = $uniq_count{$uniq_seqs[$i]};
	print ABN ">$uniq_seqs[$i]: $uniq_count{$uniq_seqs[$i]} \+\n"; ## print seq and original abundances to file
	if ($i % 1000 == 0) {print "\t$i longest seqs merged\n"}
	 
	my $lengthi = length($uniq_seqs[$i]);
	# print "$uniq_count{$uniq_seqs[$i]}\t$lengthi\t$i\t\t$uniq_seqs[$i]\n" unless $uniq_seqs[$i] eq "KDS";
	# foreach my $uniq_seq (@uniq_seqs) {print "\t\t\t\t\t$uniq_seq\n" }

	for (my $j = $i+1; $j < @uniq_seqs; $j++) {
		# print "\t\t\t$j\n";
		
		## compare each seq to subsequent seqs
		if ($uniq_seqs[$i] =~ /$uniq_seqs[$j]/ and $uniq_seqs[$i] ne $uniq_seqs[$j]) { 
			# my $lengthj = length($uniq_seqs[$j]);
			# print "$uniq_count{$uniq_seqs[$j]}\t$lengthj\t$i\t$j\t$uniq_seqs[$j]\n";
			
			## weight subseqs by their proportion of longest seq * how many identical subseqs there are
			my $proportion = (length($uniq_seqs[$j]) / length($uniq_seqs[$i]));
			my $weight = $proportion * $uniq_count{$uniq_seqs[$j]};
			 
			$final_count{$uniq_seqs[$i]} += $weight; ## increase the final weight tally by subseq weights
			printf ABN "\t%.2f * %d\n", $proportion, $uniq_count{$uniq_seqs[$j]};
			splice @uniq_seqs, $j, 1, "KDS"; ## remove the subseqs from the array so they're not repeated
			
			# foreach my $uniq_seq (@uniq_seqs) {print "\t\t\t\t\t$uniq_seq\n"}
		}	
	}
}

close ABN;

my @final_seqs = sort {length($b) <=> length($a)} keys %final_count;
my $k = 1;

foreach my $seq (@final_seqs) {
	printf OUT ">%d:N%.2f\n%s\n", $k, $final_count{$seq}, $seq;
	$k++;
}


close OUT;