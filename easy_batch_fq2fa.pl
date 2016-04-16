#!/usr/bin/perl
# easy_batch_fq2fa.pl
use strict; use warnings;

# This script makes it easy to batch use "fastq_to_fasta" from the "fastx_toolkit".
# Normally it's difficult to batch change the extension of the output files form "fastq_to_fasta".
# This script makes it easier.
# However, this script only operates on one file at a time, and still requires a for loop in the command line
# to make it work on multiple files.  It's written with the expectation that the fastq files were produced
# by "process_shortreads" in the "stacks" module
# EXAMPLE:
# for file in `ls [mz]*fq*` ; do ../../Perl_scripts/easy_batch_fq2fa.pl $file ./Fasta_files ; done
# Do NOT include the "/" at the end of the output directory name, but DO include whole path or "./" if in 
# working directory.
 
die "Usage easy_batch_fq2fa.pl <fastq file> <output directory>\n" unless @ARGV == 2;

my ($file_name) = $ARGV[0] =~ /^(\w+)\.[fr]/;
my ($extension) = $ARGV[0] =~ /\.(\w+\.*\w*)$/;
my ($output_directory) = $ARGV[1];
chomp $output_directory;
my ($new_extension);
if ($extension =~ /fq_1/) {
	$new_extension = "fa_1";
}
elsif ($extension =~ /fq_2/) {
	$new_extension = "fa_2";
}
elsif ($extension =~ /rem.fq/) {
	$new_extension = "rem.fa";
}
else {die "Error: unexpected file extensions\n"}

system("fastq_to_fasta -i $ARGV[0] -o $output_directory/$file_name.$new_extension -Q 33");