#!/usr/bin/perl
# no_hits_vjblast_seqs.pl
use strict; use warnings;
use Getopt::Long;

# use this script after extracting the query ids from .[vj]blast files for the "No hits found" seqs
# To run this script best, concatenate all of the fasta files your interested in getting the seqs from 

my $usage = "\n\tUsage: no_hits_vjblast_seqs.pl [-h] -t <no_hits_ids.txt> -f <FASTA file>\n\n";

# defaults
my $help;
my $text;
my $fasta;

GetOptions (
	'help!' => \$help,
	't=s'   => \$text,
	'f=s'   => \$fasta,
) or die $usage;

die $usage unless $help or ($fasta and $text);

if ($help) {
	help_text();
}
else {
	open TXT, "<$text"  or die "\n\tError: cannot open $text\n\n";
	open FSA, "<$fasta" or die "\n\tError: cannot open $fasta\n\n";
	open OUT, ">$fasta.nohits" or die "\n\tError: cannot create $fasta.nohits\n\n";

	my @no_hits_ids;
	while (<TXT>) {
		my $id = $_;
		chomp $id;
		push @no_hits_ids, $id;
	}

	while (<FSA>) {

		if ($_ =~ /^\>/) {
			my ($id) = /^\>(\w+)/;
			my ($seq) = <FSA> =~ /^([ACGTN]+)/;
			
			if (grep /$id/, @no_hits_ids) {
				print OUT ">$id\n$seq\n";
			}
		}
	}
}

sub help_text {
	print $usage;
}