#!/usr/bin/perl
# bt2_get_primer_aligned.pl
use strict; use warnings;

my $usage = "\n\tbt2_get_primer_aligned.pl <sample ID>\n\n";

die $usage unless @ARGV == 1;

my $sample = $ARGV[0];

my ($fq1) = glob "$sample.fq_1*fq";
my ($fq2) = glob "$sample.fq_2*fq";
my ($fqr) = glob "$sample.rem.fq*fq";
my $sam1 = "$sample.fq_1.primer.sam";
my $sam2 = "$sample.fq_2.primer.sam";
my $samr = "$sample.rem.fq.primer.sam";

open SAM1, "<$sam1" or die "\n\tError: cannot open $sam1\n\n";
open SAM2, "<$sam2" or die "\n\tError: cannot open $sam2\n\n";
open SAMR, "<$samr" or die "\n\tError: cannot open $samr\n\n";
my (%sam1_ids, %sam2_ids, %samr_ids);

while (<SAM1>) {

	if ($_ !~ /^@/) {
		my ($seq_id)   = /^(\w+)\t/;
		my ($primer_id) = /$seq_id\t\d+\t((fwd_\d{2}|rev_[mz]))\t/;
		$sam1_ids{$seq_id} = $primer_id;
	}
}

while (<SAM2>) {

	if ($_ !~ /^@/) {
		my ($seq_id)   = /^(\w+)\t/;
		my ($primer_id) = /$seq_id\t\d+\t((fwd_\d{2}|rev_[mz]))\t/;
		$sam2_ids{$seq_id} = $primer_id;
	}
}

while (<SAMR>) {

	if ($_ !~ /^@/) {
		my ($seq_id)   = /^(\w+)\t/;
		my ($primer_id) = /$seq_id\t\d+\t((fwd_\d{2}|rev_[mz]))\t/;
		$samr_ids{$seq_id} = $primer_id;
	}
}

close SAM1; close SAM2; close SAMR;

open FQ1, "<$fq1"                     or die "\n\tError: cannot open $fq1\n\n";
open FQ2, "<$fq2"                     or die "\n\tError: cannot open $fq2\n\n";
open FQR, "<$fqr"                     or die "\n\tError: cannot open $fqr\n\n";
open FWD, ">$sample.fwd.fa"           or die "\n\tError: cannot create $sample.ig.1.fa\n\n";
open REV, ">$sample.rev.fa"           or die "\n\tError: cannot create $sample.ig.2.fa\n\n";
open NPR, ">$sample.npr.fa"           or die "\n\tError: cannot create $sample.ig.rem.fa\n\n";
open CSV, ">$sample\_bt2_u_stats.csv" or die "\n\tError: cannot create $sample\_bt2_stats.csv\n\n";
print CSV "sample,seq.id,primer\n";

while (<FQ1>) {

	if ($_ =~ /^@[ACGT]{5}_\d_.+1$/) {
		my ($seq_id) = /@(\w+)/;
		my $seq = <FQ1>;
		chomp $seq;

		if (exists $sam1_ids{$seq_id}) {

			if ($sam1_ids{$seq_id} =~/fwd/) {
				print FWD "\>$seq_id:$sam1_ids{$seq_id}\n$seq\n";
				print CSV "$sample,$seq_id,$sam1_ids{$seq_id}\n";
			}
			elsif ($sam1_ids{$seq_id} =~/rev/) {
				print REV "\>$seq_id:$sam1_ids{$seq_id}\n$seq\n";
				print CSV "$sample,$seq_id,$sam1_ids{$seq_id}\n";	
			}
			else {
				print NPR "\>$seq_id:$sam1_ids{$seq_id}\n$seq\n";
				print CSV "$sample,$seq_id,$sam1_ids{$seq_id}\n";
			}
		}
	}
}

close FQ1;

while (<FQ2>) {

	if ($_ =~ /^@[ACGT]{5}_\d_.+2$/) {
		my ($seq_id) = /@(\w+)/;
		my $seq = <FQ2>;
		chomp $seq;

		if (exists $sam2_ids{$seq_id}) {

			if ($sam2_ids{$seq_id} =~/fwd/) {
				print FWD "\>$seq_id:$sam2_ids{$seq_id}\n$seq\n";
				print CSV "$sample,$seq_id,$sam2_ids{$seq_id}\n";
			}
			elsif ($sam2_ids{$seq_id} =~/rev/) {
				print REV "\>$seq_id:$sam2_ids{$seq_id}\n$seq\n";
				print CSV "$sample,$seq_id,$sam2_ids{$seq_id}\n";	
			}
			else {
				print NPR "\>$seq_id:$sam2_ids{$seq_id}\n$seq\n";
				print CSV "$sample,$seq_id,$sam1_ids{$seq_id}\n";
			}
		}
	}
}

close FQ2;

while (<FQR>) {

	if ($_ =~ /^@[ACGT]{5}_\d_.+[12]$/) {
		my ($seq_id) = /@(\w+)/;
		my $seq = <FQR>;
		chomp $seq;

		if (exists $samr_ids{$seq_id}) {

			if ($samr_ids{$seq_id} =~/fwd/) {
				print FWD "\>$seq_id:$samr_ids{$seq_id}\n$seq\n";
				print CSV "$sample,$seq_id,$samr_ids{$seq_id}\n";
			}
			elsif ($samr_ids{$seq_id} =~/rev/) {
				print REV "\>$seq_id:$samr_ids{$seq_id}\n$seq\n";
				print CSV "$sample,$seq_id,$samr_ids{$seq_id}\n";	
			}
			else {
				print NPR "\>$seq_id:$samr_ids{$seq_id}\n$seq\n";
				print CSV "$sample,$seq_id,$samr_ids{$seq_id}\n";
			}
		}
	}
}

close FQR; close FWD; close REV; close NPR; close CSV;