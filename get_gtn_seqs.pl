#!/usr/bin/perl
# get_gtn_seqs.pl
use strict; use warnings;
use Getopt::Long;

# Use this script to get the unique seqs that have an N > n

my $usage = "\n\tUsage: get_gtn_seqs.pl [options: -h -n <N cutoff> -s <sort?>] -i <unique seqs fasta file> \n\n";

#defaults
my $infile;
my $n = 1;
my $help;
my $sort;

GetOptions (
	'i=s'   => \$infile,
	'n=i'   => \$n,
	'help!' => \$help,
	'sort!' => \$sort,
) or die $usage;

die $usage unless $help or ($infile =~ /uniq/);
die $usage unless defined $infile or $help;

if ($help) {
	print $usage;
	print "\t\t-h: this helpful help screen\n";
	print "\t\t-n: the upper limit of abundances you want to exlude, default 1\n";
	print "\t\t(e.g. if n=2, only seqs of n=3 or more will be written ot the outfile)\n";
	print "\t\t-i: the input file\n\n";
} 
else {
	my ($filename) = $infile =~ /(.+)\.fa*s*t*a$/;
	my ($extension) = $infile =~ /\.(fa*s*t*a)$/;
	if ($sort) {$extension = "sorted.$extension"}
	
	open IN, "<$infile" or die "\n\tError: cannot open $infile\n\n";
	open OUT, ">$filename.gt$n.$extension", or die "\n\tError: cannot create $filename.gt$n.$extension\n\n";
	if ($sort) {
		my %abunds_by_id;
		my %seqs_by_id;
		while (<IN>) {
			if ($_ =~ /^\>/) {
				my ($seqn) = $_ =~ /-(\d+)$/;
				if ($seqn > $n) {
					my $id = $_;
					my $seq =<IN>;
					chomp ($id, $seq);
					$abunds_by_id{$id} = $seqn;
					$seqs_by_id{$id} = $seq;
				}
			}
		}
		my @ids = sort {$abunds_by_id{$b} <=> $abunds_by_id{$a}} keys %abunds_by_id;
		for my $id (@ids) {
			print OUT "$id\n$seqs_by_id{$id}\n";
		}
	}
	else {
		while (<IN>) {
			if ($_ =~ /^\>/) {
				my ($seqn) = $_ =~ /-(\d+)$/;
				if ($seqn > $n) {
					my $id = $_;
					my $seq = <IN>;
					chomp($id, $seq);
					# if ($id !~ /bp/) {
					# 	my $seqlen = length $seq;
					# 	print OUT "$id:${seqlen}bp\n$seq\n";
					# } else {
					# 	print OUT "$id\n$seq\n";
					# }
					print OUT "$id\n$seq\n";
				}
			}
		}
	}
}

close IN ; close OUT;




