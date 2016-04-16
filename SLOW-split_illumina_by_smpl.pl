#!/usr/bin/perl
# split_illumina_by_smpl.pl
use strict; use warnings;
use Getopt::Long;

# use this script to split a 4-read (indexed) Hi- or MiSeq run into samples
# requires a TSV file with samples and their two barcodes as well as four read files
# this script relies implicitly on the fact that the read files be organized *identically*

my $usage = "\n\tsplit_illumina_by_smpl.pl [-h -o] -b -1 -2 -3 -4\n\n";

# defaults 
my $help;
my $outdir = './';
my $bcFile;
my $read1File;
my $read2File;
my $read3File;
my $read4File;

GetOptions (
	'help!' => \$help,
	'o=s'   => \$outdir,
	'b=s'   => \$bcFile,
	'1=s'   => \$read1File,
	'2=s'   => \$read2File,
	'3=s'   => \$read3File,
	'4=s'   => \$read4File,
	) or die $usage;

if ($outdir !~ /\/$/) {$outdir = "$outdir\/"}
die $usage unless $help or ($bcFile and $read1File and $read2File and $read3File and $read4File);

if ($help) {help_txt()}
else {
	# global variables
	my %smpl_cat_bcs;
	my ($lane) = $read1File =~ /lane(\d+)/;

	# the first step is to get each sample, its barcodes, concatenate the barcodes and hash them with the sample
	open BCS, "<$bcFile" or die "\n\tError: cannot open $bcFile\n\n";

	while (<BCS>) {
		my ($smpl) = /^(\S+)\t/;
		my ($bc1)  = /^$smpl\t([ACGT]+)\t/;
		my ($bc2)  = /\t([ACGT]+)$/;
		my $index = "${bc1}${bc2}";
		$smpl_cat_bcs{$index} = $smpl;
	}
	close BCS;

	open RD1, "<$read1File" or die "\n\tError: cannot open $read1File\n\n";
	open RD2, "<$read2File" or die "\n\tError: cannot open $read2File\n\n";
	open RD3, "<$read3File" or die "\n\tError: cannot open $read3File\n\n";
	open RD4, "<$read4File" or die "\n\tError: cannot open $read4File\n\n";

	while (my $line1 = <RD1>) {
		my $line2 = <RD2>; my $line3 = <RD3>; my $line4 = <RD4>;

		my $header1 = $line1;
		my $header4 = $line4;

		my $seq1 = <RD1>; my $seq2 = <RD2>; my $seq3 = <RD3>; my $seq4 = <RD4>;

		$line1 = <RD1>; $line2 = <RD2>; $line3 = <RD3>; $line4 = <RD4>;

		my $qual1 = <RD1>; my $qual4 = <RD4>;

		$line2 = <RD2>; $line3 = <RD3>;

		chomp($header1, $header4, $seq1, $seq2, $seq3, $seq4, $qual1, $qual4);

		my $index = "${seq2}${seq3}";
		my $smpl = $smpl_cat_bcs{$index};
		unless ($smpl) {$smpl = "lane${lane}_unmatched"}

		open OR1, ">>${outdir}${smpl}_R1.fastq" or die "Error: cannot open ${outdir}${smpl}_R1.fastq\n\n";
		open OR2, ">>${outdir}${smpl}_R2.fastq" or die "Error: cannot open ${outdir}${smpl}_R2.fastq\n\n";

		print OR1 "$header1\n$seq1\n+\n$qual1\n";
		print OR2 "$header4\n$seq4\n+\n$qual4\n";

		close OR1; close OR2;
	}
	close RD1; close RD2; close RD3; close RD4;
}


sub help_txt {
	print $usage;
}