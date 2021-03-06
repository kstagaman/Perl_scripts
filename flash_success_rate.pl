#!/usr/bin/perl
# flash_success_rate.pl
use strict; use warnings;

my $usage = "\n\tflash_success_rate.pl JOBNAME.oJOBNUMBER\n\tUse this script to get percentage of successful read assemblies from the STDOUT file from a PBS job that ran FLASH\n\n";

die $usage unless @ARGV == 1;

my $infile = $ARGV[0];

open INF, $infile or die "\n\t$infile cannot be opened\n\n";

while (<INF>) {
	if ($_ =~ /^\[FLASH\]/) {
		if ($_ =~ /-R1.fastq/) {
			my ($smpl) = /(\S+)-R1.fastq/;
			print "$smpl\t";
		}

		if($_ =~ /Percent combined/) {
			my ($pc_comb) = /(Percent combined: [\d\.\%]+)/;
			print "$pc_comb\n";
		}
	}
}

close INF;