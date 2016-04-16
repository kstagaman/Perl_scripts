#!/usr/bin/perl
# submit_mafft_jobs.pl
use strict; use warnings;
use Getopt::Long;


my $usage = 'Usage: submit_mafft_jobs.pl -regex <"file regex"> -outdir <PATH>';

# defaults
my $regex;
my $outdir = './';

GetOptions (
	'regex=s'  => \$regex,
	'outdir=s' => \$outdir,
) or die "\n\t$usage\n\n";

if ($outdir !~ /\/$/) {$outdir="$outdir\/"}

my @files = glob $regex;
my $pwd = `pwd`;
my ($curdir) = $pwd =~ /^\/ibrix(\S+)/;

foreach my $file (@files) {
	my $lines = `grep -c "^>" $file`;
	next if ($lines <= 1);
	
	my ($seg) = $file =~ /\.([VJ]m*\d{1,2})\./;

	open OUT, ">${outdir}mafft_$seg.job" or die "\n\tError: cannnot create ${outdir}mafft_$seg.job\n\n";

	print OUT "#!/bin/bash -l
	# mafft.job


	#PBS -N mafft_$seg
	#PBS -d $curdir

	#PBS -q fatnodes

	#PBS -k eo
	#PBS -m abe
	#PBS -M stagaman\@uoregon.edu


	###### variables ######
	## no quotes needed  ##

	infile=$file
	outfile=$file.mafft

	#######################

	mafft --auto --thread 32 \$infile > \$outfile\n";
}

