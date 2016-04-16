#!/usr/bin/perl
# classify_seqs_testjv_ksize_stats.pl
use strict; use warnings;

die "Usage: classify_seqs_jv_ksize_stats.pl <v/jm/jz>\n" unless @ARGV == 1;
die "Usage: classify_seqs_jv_ksize_stats.pl <v/jm/jz>\n" unless $ARGV[0] =~ /[vj][mz]*/i;

my ($type) = $ARGV[0];
my $seg_type;
if    ($type =~ /v/i)  {$seg_type = "V"}
elsif ($type =~ /jm/i) {$seg_type = "Jm"}
else                   {$seg_type = "Jz"}

my @files = `ls *ksize*$seg_type*.taxonomy`;
chomp @files;

my @original_segs;
my @nums_mutations;
my @ksizes;
my @assigned_segs;
my @bootstrap_values;

foreach my $file (@files) {
	open IN, "<$file" or die "Error: cannot open $file\n";
	
	while (<IN>) {
		my ($raw_original_seg) = $_ =~ /^($seg_type\d{1,2})\s+\S/;
		
		my $original_seg;
		if ($seg_type =~ /J/) {
			($original_seg) = code_jseg($raw_original_seg);
		}
		else {
			($original_seg) = $raw_original_seg =~ /V(\d{1,2})/;
		}
		
		my ($num_mutations)     = $file =~ /mutated(\d{1,3})x/;
		my ($ksize)             = $file =~ /ksize(\d{1,2})/;
		my ($raw_assigned_seg) = $_    =~ /\s+($seg_type\d{1,2})/;
		
		my $assigned_seg;
		if ($seg_type =~ /J/) {
			($assigned_seg) = code_jseg($raw_assigned_seg);
		}
		else {
			($assigned_seg) = $raw_assigned_seg =~ /V(\d{1,2})/;
		}
		
		my ($bootstrap_value)   = $_    =~ /$seg_type\d{1,2}\((\d{1,3})\)\;/;
		last if ($_ =~ /^\s+/);
		push @original_segs, $original_seg;
		push @nums_mutations, $num_mutations;
		push @ksizes, $ksize;
		push @assigned_segs, $assigned_seg;
		push @bootstrap_values, $bootstrap_value;
	}
		
	close IN;
}

open OUT, ">test_$type.stats.csv";

print OUT "original_seg,num_mutations,ksize,assigned_seg,bootstrap_value,match\n";

for (my $i = 0; $i < @original_segs; $i++) {
	print OUT "$original_segs[$i],$nums_mutations[$i],$ksizes[$i],$assigned_segs[$i],$bootstrap_values[$i],";
	if ($original_segs[$i] == $assigned_segs[$i]) {
		print OUT "1\n";
	}
	else {
		print OUT "0\n";
	}
}

close OUT;

# subroutines

sub code_jseg {
	my ($raw_assigned_seg) = @_;
	my $assigned_seg;
	if    ($raw_assigned_seg =~ /Jm1/) {$assigned_seg = 1}
	elsif ($raw_assigned_seg =~ /Jm2/) {$assigned_seg = 2}
	elsif ($raw_assigned_seg =~ /Jm3/) {$assigned_seg = 3}
	elsif ($raw_assigned_seg =~ /Jm4/) {$assigned_seg = 4}
	elsif ($raw_assigned_seg =~ /Jm5/) {$assigned_seg = 5}
	elsif ($raw_assigned_seg =~ /Jz1/) {$assigned_seg = 6}
	elsif ($raw_assigned_seg =~ /Jz2/) {$assigned_seg = 7}
	return $assigned_seg;
}

	