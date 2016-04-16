#!/usr/bin/perl
# assign_jm.pl
use strict; use warnings;

# use this script to take info from a classify.seqs (mothur) output .taxonomy file to add the Jm assignment to the ID line
# run this script in the file containing the .taxonomy files, specify the location of the desired fasta files in the command line
# example: $ ./assign_jm.pl ../Process_shortreads_output_fasta06/Ordered_trunc_amplicon_files/

die "Usage: assign_jm.pl <directory path to IgM reverse reads>\n" unless @ARGV == 1;

my ($path) = $ARGV[0];

my @tax_files = `ls *.Jm.taxonomy`;
my @igm_files = `ls $path*IgM*.rev.noprimer.fa`;
chomp(@tax_files, @igm_files);

for (my $i = 0; $i < @tax_files; $i++) {
	my ($tag) = $tax_files[$i] =~ /(\w+\.*\d*\.rev.noprimer)/;
	my @id_jsegs;
	my @seqs;
	
	open TAX, "<$tax_files[$i]" or die "Error: cannot open $tax_files[$i]\n";
	open IGM, "<$igm_files[$i]" or die "Error: cannot open $igm_files[$i]\n";
	
	while (<TAX>) {
		my ($id) = $_ =~ /^(\d.+95)/;
		my ($jseg) = $_ =~ /(Jm\d)/;
		my ($id_jseg) = join(":", $id, $jseg);
		push @id_jsegs, $id_jseg;
	}
	
	while (<IGM>) {
		if ($_ !~ /^\>/) {
			my ($seq) = $_;
			chomp $seq;
			push @seqs, $seq;
		}
	}
	
	open OUT, ">$tag.jm.fa" or die "Error: cannot create $tag.jm.fa\n";
	
	for (my $j = 0; $j < @seqs; $j++) {
		print OUT "\>$id_jsegs[$j]\n$seqs[$j]\n";
	}		
}