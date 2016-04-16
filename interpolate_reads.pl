#!/usr/bin/perl
# interpolate_reads.pl
use strict; use warnings;

die "usage: interpolate_reads.pl <file1.tsv> <file2.tsv>" unless @ARGV == 2;

open(READ1, "<$ARGV[0]") or die "Error reading read1 file";
my @read1s = <READ1>;
my ($barcode) = $read1s[1] =~ /\t\d\t([ACGT]{5})/;
close READ1;

open(READ2, "<$ARGV[1]") or die "Error reading read2 file";
my @read2s = <READ2>;
close READ2;

my @unpaired_read1s = ();
my @unpaired_read2s = @read2s;
my $num_read1s = @read1s;


open(OUT, ">$barcode\_bothreads.tsv");

for (my $i = 0; $i < @read1s; $i++) {
	my $read1 = $read1s[$i];
	my ($location1) = $read1 =~ /\d\t\d{4}\t(\d+\t\d+)\t\d{1}/;
	my $k = 0;
	my $current_read1 = $i + 1;
	print "$current_read1 of $num_read1s 1st reads done\n";
	
	for (my $j = 0; $j < @read2s; $j++) {
		my $read2 = $read2s[$j];
		my ($location2) = $read2 =~ /\d\t\d{4}\t(\d+\t\d+)\t\d{1}/;
		
		if ($location1 =~ $location2) {
			$k++;
			print OUT "$read1";
			print OUT "$read2";
			splice(@unpaired_read2s, $j, 1, "\_");
			last;
		}
	}	
	if ($k == 0) {
		push(@unpaired_read1s, $read1);
	}
}

foreach my $unpaired_read1 (@unpaired_read1s) {
	print OUT "$unpaired_read1";
}


foreach my $unpaired_read2 (@unpaired_read2s) {
	print OUT "$unpaired_read2" unless $unpaired_read2 =~ /\_/;
}

close OUT;



	