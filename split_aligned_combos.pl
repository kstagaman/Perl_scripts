#!/usr/bin/perl
# split_aligned_combos.pl
use warnings;


my $usage = "\n\tUsage: split_aligned_combos.pl <FASTA file>\n\n";

die $usage unless @ARGV == 1;
open IN, "<$ARGV[0]" or die "\n\tError: cannot open $ARGV[0]\n\n";

my $num_vsegs = 39;
my $num_jsegs = 5;
my @handles;
my $k = 0;
my ($jtype) = $ARGV[0] =~ /J([mz])/;

for (my $i=1; $i <= $num_vsegs; $i++) {

	for (my $j=1; $j <= $num_jsegs; $j++) {

		if (length $i == 1) {$i = "0$i"}
		my $handle = "V${i}J$jtype$j";
		push @handles, $handle;
		open $handle, ">all_${handle}_combos.fa" or die "\n\tError: cannot create all_${handle}_combos.fa\n\n";
		$k++;
	}
}

print "\t$k combo files created\n";

my $l = 0;

while (<IN>) {

	if ($_ =~ /^\>/) {
		my $id = $_;
		my ($vseg) = /:(V\d{2}):/;
		my ($jseg) = /:(J[mz]\d):/;
		my $seq = <IN>;
		chomp ($id, $seq);
		my $handle = "$vseg$jseg";
		
		print $handle "$id\n$seq\n";
		
		$l++;

	}
}
close IN;

print "\t$l sequences written\n";

foreach my $handle (@handles) {
	close $handle;
}