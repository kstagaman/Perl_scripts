#!/usr/bin/perl
# rename_process_shortreads.pl
use strict; use warnings;

# use this script in the directory containing the files with the names you want to change

die "Usage: rename_process_shortreads.pl <barcode file.csv>\n" unless @ARGV==1;

open BCS, "<$ARGV[0]" or die "Error cannot open $ARGV[0]"

my %barcodes = ();

while (<BCS>) {
	my ($sample) = $_ =~ /^(\w+)\t/;
	my ($barcode) = $_ =~ /\t([ACGT]+)$/;
	$barcodes{$sample}=$barcode;
}

my @files = `ls *.f[aq] *.f[aq]_[12]`;


foreach my $sample (sort keys %barcodes) {
	foreach my $file (@files) {
		if ($file =~ /$barcodes{$sample}/) {
			chomp $file;
			my ($type) = $file =~ /[ACGT]\.(\S{4,6})/;
		    my ($ne../w_file) = "$sample\.$type";
		    system("mv $file $new_file");
		}
	}
}
