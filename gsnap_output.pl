#!/usr/bin/perl
# gsnap_output.pl
use strict; use warnings;

my $usage = "\n\tgsnap_output.pl <SAM file>\n\n";

die $usage unless @ARGV == 1;
my ($filename) = $ARGV[0] =~ /(\S+)\.sam$/;

# DEFAULTS
my $mq_thresh = 10;
my $tl_thresh = 10000;

open IN, "<$ARGV[0]" or die "\n\tError: cannot open $ARGV[0]\n\n";
open SAM, ">$filename.mq${mq_thresh}tl$tl_thresh.sam" or die "\n\tError: cannot create $filename.mqtl_ctrl.sam\n\n";

my %seq_ids;

while (<IN>) {
	if ($_ =~ /^@/) {
		print SAM $_;
	}
	else {
		my ($seq_id) = /^(\w+)\t/;
		my ($map_qual) = /^$seq_id\t\d+\t3\t\d+\t(\d+)\t/;
		my ($temp_len) = /^$seq_id\t\d+\t3\t\d+\t$map_qual\t\w+\t\=\t\d+\t\-*(\d+)\t/;
		
		if ($map_qual > $mq_thresh and $temp_len > $tl_thresh) {
			print SAM $_;
			$seq_ids{$seq_id}++;
		}
	}
}

close IN; close SAM;

open SAM, "<$filename.mq${mq_thresh}tl$tl_thresh.sam";
open REV, ">$filename.rev.fa" or die "\n\tError: cannot create $filename.rev.fa\n\n";
open FWD, ">$filename.fwd.fa" or die "\n\tError: cannot create $filename.fwd.fa\n\n";

while (<SAM>) {

	if ($_ !~ /^@/) {
		my ($seq_id)    = /^(\w+)\t/;
		my ($start_pos) = /^$seq_id\t\d+\t3\t(\d+)\t/;
		my ($seq)       = /\t([ACGT]+)\t/;
		
		if ($start_pos > 34052965 and $start_pos < 34056600) {
			print REV "\>$seq_id:$start_pos\n$seq\n";
		}
		elsif ($start_pos > 34056600) {
			print FWD "\>$seq_id:$start_pos\n$seq\n";
		}
	}
}

close SAM; close FWD; close REV;

my @uniq_ids = sort {$seq_ids{$a} <=> $seq_ids{$b}} keys %seq_ids;
my $num_ids = @uniq_ids;

# foreach my $uniq_id (@uniq_ids) {
# 	print "$uniq_id:\t$seq_ids{$uniq_id}\n";
# }

print "\t$ARGV[0]\t$num_ids unique ids (MQ > $mq_thresh, |Temp Len| > $tl_thresh)\n";