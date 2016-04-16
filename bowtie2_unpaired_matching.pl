#!/usr/bin/perl
# bowtie2_unpaired_matching.pl
use strict; use warnings;

# TO DO: need to figure out a way to go through whole *_bt2_u_stats.csv and find just the paired reads (with both 1 & 2)
# maybe try sorting file first (or counting gen_seq_ids?)


my $usage = "\n\tbowtie2_unpaired_matching.pl <CSV file>\n\n";

die $usage unless @ARGV == 1;

my $infile = $ARGV[0];
my ($sample) = $infile =~/^([mz][abcd]\d{2})/;
# my %read1s;
# my %read2s;
# my @gen_seq_ids;

open OUT, ">$sample.matched_and_paired.csv" or die "\n\tError: cannot create $sample.matched_and_paired.csv";
print OUT "sample,seq.id,r1.match,r2.match\n";

open CSV, "<$infile" or die "\n\tError: cannot open $infile\n\n";
$_ = <CSV>;

while (<CSV>) {
	if ($_ =~ /^$sample,\w+_1,0/) {
		my ($seq_id1)     = /^$sample,(\w+),0/;
		my ($trans_name1) = /^$sample,$seq_id1,0,(.+)$/;
		my ($gen_seq_id) = $seq_id1 =~ /(\w+)_1$/;
		my $line2 = <CSV>;
		if ($line2 =~ /,$gen_seq_id\_2,/) {
			my ($trans_name2) = $line2 =~ /^$sample,$gen_seq_id\_2,0,(.+)$/;
			print OUT "$sample,$gen_seq_id,$trans_name1,$trans_name2\n";
		}
	}
}
	
	
# 	if    ($seq_id =~ /_1$/) {
# 		$read1s{$gen_seq_id}=$trans_name;
# 		push @gen_seq_ids, $gen_seq_id;
# 	} 
# 	elsif ($seq_id =~ /_2$/) {
# 		$read2s{$gen_seq_id}=$trans_name;
# 		push @gen_seq_ids, $gen_seq_id;
# 	}
# }

close CSV; close OUT;

# my @read1_ids = keys %read1s;
# my @read2_ids = keys %read2s;

# foreach my $read1_id (@read1_ids) {
# 	if(!$read2s{$read1_id}) {$read2s{$read1_id} = "NA"}
# }

# foreach my $read2_id (@read2_ids) {
# 	if (!$read1s{$read2_id}) {$read1s{$read2_id} = "NA"}
# }



# foreach my $gen_seq_id (@gen_seq_ids) {
# 	if (exists $read1s{$gen_seq_id} and exists $read2s{$gen_seq_id}) {
# 		print OUT "$sample,$gen_seq_id,1,$read1s{$gen_seq_id},$read2s{$gen_seq_id}\n";
# 	} 
# 	elsif (exists $read1s{$gen_seq_id}) {
# 		print OUT "$sample,$gen_seq_id,0,$read1s{$gen_seq_id},NA\n";
# 	}
# 	elsif (exists $read2s{$gen_seq_id}) {
# 		print OUT "$sample,$gen_seq_id,0,NA,$read2s{$gen_seq_id}\n";
# 	}
# }