#!/usr/bin/perl
# seg_assign_concordance.pl
use strict; use warnings;
use Getopt::Long;

# Use this script to take fasta files that have been aligned using gsnap or bowtie2, and confirmed/specified their V and J assignments with either classify.seqs() [V seg] or bowtie2 [J seg], and then find the concordance between what's been assigned.

# This scripts outputs a CSV file that can be used for analysis

# Things that need to be determined from output (in R):
	# Number of matching assignments
	# Number of mismatching assignments
	# Number of vague to specific conversions
	# Number of unassigned in both methods

my $usage = "\n\tUsage: seg_assign_concordance.pl [options: -h] -s <sample id>\n\n";

# defaults
my $help;
my $sample;

GetOptions (
	'help!' => \$help,
	's=s'   => \$sample,
) or die $usage;

die $usage unless $sample or $help;

if ($help) {help_text()}
else {
	my $fwd = glob "$sample*fwd*sorted.V.taxonomy";
	my $rev = glob "$sample*rev*sorted.jm.sam";

	open CSV, ">$sample.concordance.csv" or die "\n\tError: cannot create $sample.concordance.csv\n\n";
	print CSV "sample,seq.id,f.align,f.primer,classify.seqs,r.align,r.primer,bt2.jseg,";
	print CSV "f.match,r.match,f.2nd.match,r.2nd.match,r.no.match\n";

	open FWD, "<$fwd" or die "\n\tError: cannot open $fwd\n\n";
	open REV, "<$rev" or die "\n\tError: cannot open $rev\n\n";

	my $fl;
	my $rl = <REV>; 

	while ($fl = <FWD>) {
		my ($fseq_id)  = $fl =~ /^(\w+)_[12]:/;
		my ($rseq_id)  = $rl =~ /^(\w+)_[12]:/;
		# print "$fseq_id\t$rseq_id\n";
		if ($fseq_id ne $rseq_id) {
			die "\n\tError: seqs are not in same order in *fwd*V.taxonomy and *rev*jm.sam files\n
			First offense:$fseq_id\t$rseq_id\n\n";
		}
		# if ($fseq_id ne $rseq_id) {print "###########\n"}

		my ($f_align)    = $fl =~ /^$fseq_id\_[12]:(igh[\w\-]+):[fr]/;
		my ($f_primer)   = $fl =~ /^$fseq_id\_[12]:$f_align:(\w+)\(/;
		my ($class_seqs) = $fl =~ /^$fseq_id\_[12]:$f_align:$f_primer\([\w\-\.]+\)\t(V\d{1,2}:[\d\-]+)\(\d/;
		my ($r_align)    = $rl =~ /^$rseq_id\_[12]:(igh[\w\-]+):[fr]/;
		my ($r_primer)   = $rl =~ /^$rseq_id\_[12]:$r_align:(\w+)\(/;
		my ($bt2_jseg)   = $rl =~ /^$rseq_id\_[12]:$r_align:$r_primer\([\w\-\.]+\)\t\d+\t((Jm\d|\*))\t/;

		my $f_match = 0;
		if ($f_align =~ /$class_seqs/) {$f_match = 1}
		my $r_match = 0;
		my ($jseg) = $bt2_jseg =~ /Jm(\d)/ unless $bt2_jseg eq '*';
		if ($bt2_jseg ne '*' and $r_align =~ /$jseg$/) {$r_match = 1}
		my $f_2nd_match = 0;
		if ($f_align =~ /ighm/ and $class_seqs) {$f_2nd_match = 1}
		my $r_2nd_match = 0;
		if ($r_align =~ /ighm/ and $bt2_jseg ne '*') {$r_2nd_match = 1}
		my $r_no_match = 0;
		if ($bt2_jseg eq '*') {$r_no_match = 1}

		print CSV "$sample,$fseq_id,$f_align,$f_primer,$class_seqs,$r_align,$r_primer,$bt2_jseg,";
		print CSV "$f_match,$r_match,$f_2nd_match,$r_2nd_match,$r_no_match\n";

		$rl = <REV>;
	}
}

close FWD; close REV; close CSV;

sub help_text {
	print $usage;
}