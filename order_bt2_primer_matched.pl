#!/usr/bin/perl
# order_bt2_primer_matched.pl
use strict; use warnings;
use Getopt::Long;

my $usage = "\n\torder_bt2_primer_matched.pl [options -h] -d <PATH to fasta files> -i <CSV stats file>\n\n";

# defaults
my $help;
my $fadir;
my $csv;

GetOptions (
	'help!' => \$help,
	'd=s'   => \$fadir,
	'i=s'   => \$csv,
) or die $usage;

die $usage unless $csv and $fadir;
if ($fadir !~ /\/$/) {$fadir = "$fadir\/"}


if ($help) {
	print $usage;
}
else {
	my ($sample) = $csv =~ /^([mz][abcd]\d{2})./;

	open CSV, "<$csv" or die "\n\tError: cannot open $csv\n\n";
	open OUT, ">$sample.bad_pairs.csv" or die "\n\tError: cannot create $sample.bad_pairs.csv\n\n";
	print OUT "sample,seq.id,type,r1.match,r2.match\n";
	my %matches;
	$_ = <CSV>;

	while (<CSV>) {
		my $bad_match = 0;
		my ($seq_id) = /^$sample,(\w+),/;
		my ($read1)  = /^$sample,$seq_id,(\S+),\S+$/;
		my ($read2)  = /^$sample,$seq_id,$read1,(\S+)$/;
		# print "$seq_id\t$read1\t$read2\n";

		if  ($read1 =~ /fwd/ and $read2 =~ /fwd/) {
			print OUT "$sample,$seq_id,f,$read1,$read2\n";
			$bad_match++;
		}
		elsif ($read1 =~ /rev/ and $read2 =~ /rev/) {
			print OUT "$sample,$seq_id,r,$read1,$read2\n";
			$bad_match++;
		}

		$matches{$seq_id} = [$read1, $read2] unless $bad_match > 0;
	}

	close CSV; close OUT;

	open FIN,  "<$fadir/$sample.fwd.fa" or die "\n\tError: cannot open $fadir/$sample.ig.1.fa\n\n";
	open RIN,  "<$fadir/$sample.rev.fa" or die "\n\tError: cannot open $fadir/$sample.ig.2.fa\n\n";
	open FOUT, ">$fadir/$sample.match_fwd.fa"  or die "\n\tError: cannot create $fadir/$sample.igv.fa\n\n";
	open ROUT, ">$fadir/$sample.match_rev.fa" or die "\n\tError: cannot create $fadir/$sample.igjc.fa\n\n";

	while (<IG1>) {
		if ($_ =~ /^\>/) {
			my ($whole_seq_id) = /^\>(\S+)/;
			my ($part_seq_id)  = /^\>(\w+)_1:/;
			my $seq = <IG1>;
			chomp $seq;

			if (exists $matches{$part_seq_id}[0]) {
				if ($matches{$part_seq_id}[0] =~ /ighv/) {
					print IGV "\>$whole_seq_id\n$seq\n";
				} else {
					print IGC "\>$whole_seq_id\n$seq\n";
				}
			}
		}
	}

	close IG1;

	while (<IG2>) {
		if ($_ =~ /^\>/) {
			my ($whole_seq_id) = /^\>(\S+)/;
			my ($part_seq_id)  = /^\>(\w+)_2:/;
			my $seq = <IG2>;
			chomp $seq;

			if (exists $matches{$part_seq_id}[1]) {
				if ($matches{$part_seq_id}[1] =~ /ighv/) {
					print IGV "\>$whole_seq_id\n$seq\n";
				} else {
					print IGC "\>$whole_seq_id\n$seq\n";
				}
			}
		}
	}

	close IG2; close IGV; close IGC;
}