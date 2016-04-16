#!/usr/bin/perl
# analyze_sequetech_results.pl
use strict; use warnings;

die "\n\tUsage: analyze_sequetech_results.pl <fasta_file> <rev_primer_seq>\n\n" unless @ARGV == 2;
die "\n\tUsage: non-nucleotide sequence submitted for reverse primer\n\n" if $ARGV[1] =~ /[QWERYUIOPSDFHJKLZXVBM]+/i;

print "\nDo you want to search for forward primers?  ";
chomp(my $answer = <STDIN>);
while ($answer !~ /[y|yes|n|no]/) {
	print "Answer yes/no, please\n";
	$answer = <STDIN>;
}

my ($file_id) = $ARGV[0] =~ /(\w+)\.[txt|fasta|fa]/;
#print "$file_id\n";
my ($rev_primer) = uc $ARGV[1];
my ($comp_seq) = revcomp($rev_primer);
my $first_four = substr $comp_seq, 0, 4;
#print "1st 4: $first_four\n";
my $last_four  = substr $comp_seq, -4;
#print "last 4: $last_four\n";
my $low_end = length($comp_seq) - 12;
my $high_end = length($comp_seq) - 4;

open FA, "<$ARGV[0]" or die "\n\tError: cannot open $ARGV[0]\n\n";

my @exact_matches = grep /$comp_seq/, <FA> ;
my $num_exact_match = @exact_matches;

close FA;
open FA, "<$ARGV[0]" or die "\n\tError: cannot open $ARGV[0]\n\n";

my @match_ends_4bp = grep /$first_four[ACGTN]{$low_end,$high_end}$last_four/, <FA>;
my $num_match_ends_4bp = @match_ends_4bp;

close FA;

my @match_ends_4bp_matches;
foreach my $ends_match_4 (@match_ends_4bp) {
	my ($match) = $ends_match_4 =~ /($first_four[ACGTN]{$low_end,$high_end}$last_four)/;
	push @match_ends_4bp_matches, $match;
}

my %match_ends_4bp_match_counts;
$match_ends_4bp_match_counts{$_}++ for @match_ends_4bp_matches;  #best way to makes counts with a hash that I've seen so far
my @uniq_matches = keys %match_ends_4bp_match_counts;

print "\nReverse primer:\n\t$rev_primer\n";
print "Complement seq:\n\t$comp_seq\n";
print "Num seqs matching whole complement seq:\n\t$num_exact_match\n";
print "Num seqs matching 4 nts on each each of complement seq:\n\t$num_match_ends_4bp\n";
foreach my $match (@uniq_matches) {
	print "\t$match: $match_ends_4bp_match_counts{$match}\n";
}


if ($answer =~ /[y|yes]/) {
	my @fwd_primers = qw/TGGTCTCCTCTGCCTTTTGT AACCATGATCGCCTCATCTC GATGGCAACAACATCCTGTG TGCATTTCAGTTCTGCTGCT ACGAATGCAGGAGTCAGACA TGTTTCAACTGTTCGTGGTCA TGGAGTTGTGTTGATGATGATT TTCATATGCACATGGTCAGTCA TGTGGTGATTGTCTTTCAAGG TGGAAAAGGAGTCAAAAAGCAT GCTTTTGTCATGTTTGCTCTCA GCTTACTGCTGCTCTCATTCAG TTTCTGCTGCTGTGCTTTAC CTGCTGTTTTCATTGGCCTTA GGTTTATACTGTCAAGGCATGG CAGCCTCAAGATGAAGAATGC CTAGTGCTGTTTCTGGCAGT CATGATCACCTCATCTCTCTGC CATGATTCTGAGCATTTTATCATGT CAATAATCAACTCACTCCTGCTG CTGCGTCCAGTGTATATTCCA TGTATTGACTGTCAGGTTGTGC TCTTTCTGCAGTTGGCAG TCTCAAAGTTGTTGGTGTCAGA CTCTCTAAACAAGTGCAAAGGTC TGGACCTTAAACTTAACTGTCTG CCATATGTTTCTGGCATCTCCC/;
	print "\nForward primers (exact matches):\n";
	open FA, "<$ARGV[0]" or die "\n\tError: cannot open $ARGV[0]\n\n";
	
	foreach my $fwd_primer (@fwd_primers) {
		my @exact_fwd_matches = grep /$fwd_primer/, <FA>;
		my $num_exact_fwd_matches = @exact_fwd_matches;
		print "\t$fwd_primer: $num_exact_fwd_matches\n";
	}
	
	close FA;
	
	my @fwd_primer_ends;
	for (my $i = 0; $i < @fwd_primers; $i++) {
		my $first_four = substr $fwd_primers[$i], 0, 4;
		my $last_four = substr $fwd_primers[$i], -4;
		my $low_end = length($fwd_primers[$i]) - 12;
		my $high_end = length($fwd_primers[$i]) - 4;
		$fwd_primer_ends[$i]->{first} = $first_four;
		$fwd_primer_ends[$i]->{last} = $last_four;
		$fwd_primer_ends[$i]->{low} = $low_end;
		$fwd_primer_ends[$i]->{high} = $high_end;
	}
	
	
	print "Forward primers (ends matches):\n";
	open FA, "<$ARGV[0]" or die "\n\tError: cannot open $ARGV[0]\n\n";
	
	for (my $j = 0; $j < @fwd_primer_ends; $j++) {
		my @fwd_ends_matches = grep /$fwd_primer_ends[$j]{first}\w{$fwd_primer_ends[$j]{low},$fwd_primer_ends[$j]{high}}$fwd_primer_ends[$j]{last}/, <FA>;
		
		my @match_fwd_ends_matches;
		foreach my $fwd_ends_match (@fwd_ends_matches) {
			my ($match) = $fwd_ends_match =~ /($fwd_primer_ends[$j]{first}\w{$fwd_primer_ends[$j]{low},$fwd_primer_ends[$j]{high}}$fwd_primer_ends[$j]{last})/;
			push @match_fwd_ends_matches, $match;
		}
		
		my %fwd_ends_match_counts;
		$fwd_ends_match_counts{$_}++ for @match_fwd_ends_matches;
		my @uniq_fwd_matches = keys %fwd_ends_match_counts;
		
		foreach my $match (@uniq_fwd_matches) {
			print "\t$match: $fwd_ends_match_counts{$match}\n";
		}
		
	}
}

open FA, "<$ARGV[0]" or die "\n\tError: cannot open $ARGV[0]\n\n";
open OUT, ">$file_id.results" or die "\n\tError: cannot create $file_id.results\n\n";

while (<FA>) {
	if ($_ =~ /^\>/) {
		print OUT $_;
		$_ = <FA>;
		my $count = 0;
		
		foreach my $uniq_match (@uniq_matches) {
			
			if ($_ =~ $uniq_match) {
				my ($seq) = $_ =~ /^([ACGTN]+$uniq_match)/;
				$count++;
				print OUT "$seq\n\n";
			}
			
		}
		
		if ($count == 0) {
			print OUT $_,"\n";
		}
	}
}


sub revcomp {
	my ($seq) = @_;
	$seq = uc($seq);
	my $rev = reverse($seq);
	$rev =~ tr/ACGTURYKMBVDH/TGCAAYRMKVBHD/; # makes complement
	return($rev);
}