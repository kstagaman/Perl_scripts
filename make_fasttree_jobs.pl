#!/usr/bin/perl
# make_fasttree_jobs.pl
use strict; use warnings;
use Getopt::Long;


my $usage = 'Usage: make_fasttree_jobs.pl -regex <"file regex"> -outdir <PATH>';

# defaults
my $regex;
my $outdir = './';

GetOptions (
	'regex=s'  => \$regex,
	'outdir=s' => \$outdir,
) or die "\n\t$usage\n\n";

die "\n\t$usage\n\n" unless $regex;

if ($outdir !~ /\/$/) {$outdir = "$outdir\/"}

my @files = glob $regex;
my $pwd = `pwd`;
my ($curdir) = $pwd =~ /^\/ibrix(\S+)/;

foreach my $file (@files) {
	my $num_seqs = `grep -c "^>" $file`;
	next if ($num_seqs < 2);

	my ($combo) = $file =~ /(V\d{2}J[mz]\d)/;

	open OUT, ">${outdir}fasttree_$combo.job" or die "\n\tError: cannot create ${outdir}fasttree_$combo.job\n\n";

	print OUT 
	"#!/bin/bash -l
# fasttree.job


#PBS -N fasttree_$combo
#PBS -d $curdir

#PBS -q fatnodes

#PBS -k eo
#PBS -m ae
#PBS -M stagaman\@uoregon.edu


###### variables ######
## no quotes needed  ##

infile=$file
outfile=$file.tree

#######################

module load fasttree

FastTree -nt -quote \$infile > \$outfile"
}