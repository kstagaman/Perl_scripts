#!/usr/bin/perl
# codon_freqs.pl
use strict; use warnings;
use Library;

die "usage: codon_freqs.pl <genbank file1> <genbank file2>\n" unless @ARGV == 2;

my $file = $ARGV[0];
my %codonfreqs1 = Library::codon_freqs($file);
my @keys1 = (sort keys %codonfreqs1);
my $numkeys1 = @keys1;

$file = $ARGV[1];
my %codonfreqs2 = Library::codon_freqs($file);
my @keys2 = (sort keys %codonfreqs2);
my $numkeys2 = @keys2;

die "usage: codon_freqs.pl <the number of codons from each genome is unequal>\n" unless $numkeys1 == $numkeys2;

print "\nCODON\tK-L DISTANCE\n";

for (my $i = 0; $i < @keys1; $i++) {
	my $KLdistance = $codonfreqs1{$keys1[$i]} * log($codonfreqs1{$keys1[$i]} / $codonfreqs2{$keys2[$i]});
	printf "%s\t%.5f\n", $keys1[$i], $KLdistance;
}







#print "\nCODON\tFREQUENCY\n";

#	for (my $n = 0; $n < @keys1; $n++) {
#		printf "%s\t%.3f\n", $keys1[$n], $codonfreqs1{$keys1[$n]};
#	}
#print "\nCODON\tFREQUENCY\n";

#	for (my $n = 0; $n < @keys2; $n++) {
#		printf "%s\t%.3f\n", $keys2[$n], $codonfreqs2{$keys2[$n]};
#	}