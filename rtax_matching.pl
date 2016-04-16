#!/usr/bin/perl
# rtax_matching.pl
use strict; use warnings;
use Getopt::Long;

my $usage = "\n\tUsage: rtax_matching.pl [options -h -q -o <PATH>] -1 <read1 FASTA> -2 <read2 FASTA> -r <rep_set FASTA>\n\n";

# defaults
my $help;
my $quiet;
my $outdir = './';
my $read1;
my $read2;
my $rep_set;

GetOptions (
	'help!'  => \$help,
	'quiet!' => \$quiet,
	'o=s'    => \$outdir,
	'1=s'    => \$read1,
	'2=s'    => \$read2,
	'r=s'    => \$rep_set,
) or die $usage;

die $usage unless $read1 and $read2 and $rep_set or $help;
if ($outdir !~ /\/$/) {$outdir = "$outdir\/"}

if ($help) {help_text()}
else {
	my @rep_ids;

	open REP, "<$rep_set" or die "\n\tError: cannot open $rep_set\n\n";

	while (<REP>) {
		if ($_ =~ /^\>/) {
			my ($id) = / (\S+)$/;
			push @rep_ids, $id;
			# print "id: $id\n";
		}
	}
	close REP;
	print "\trep set ids collected...\n" unless $quiet;

	open R1I, "<$read1" or die "\n\tError: cannot open $read1\n\n";
	open R2I, "<$read2" or die "\n\tError: cannot open $read2\n\n";
	open R1O, ">$outdir/$read1.out" or die "\n\tError: cannot create $outdir/$read1.out\n\n";
	open R2O, ">$outdir/$read2.out" or die "\n\tError: cannot create $outdir/$read2.out\n\n";

	my $l1;
	my $l2 = <R2I>;
	my $n = 0;

	while ($l1 = <R1I>) {
		if ($l1 =~ /^\>/ and $l2 =~ /^\>/) {
			my ($id1) = $l1 =~ /^\>(\S+) /;
			# print "id1: $id1\n";
			my ($id2) = $l2 =~ /^\>(\S+) /;
			# print "id2: $id2\n";
			my $header1 = $l1;
			my $header2 = $l2;
			my $seq1 = <R1I>;
			my $seq2 = <R2I>;
			chomp ($header1, $header2, $seq1, $seq2);

			if (grep /^$id1$/, @rep_ids) {
				print R1O "$header1\n$seq1\n";
				print R2O "$header2\n$seq2\n";
				
			}
			$n++;
			if ($n % 10000 == 0) {print "\t$n reads processed...\n" unless $quiet}
		}
		
		$l2 = <R2I>;
	}
	close R1I; close R2I; close R1O; close R2O;
	print "\t$n reads processed\n" unless $quiet;
}



sub help_text {
	print $usage;
	print "\t\t-h: this helpful help screen\n";
	print "\t\t-q: prevent printing of progress to STDOUT\n";
	print "\t\t-o: directory to write output to (default current)\n";
	print "\t\t-1: FASTA file containing read 1 sequences\n";
	print "\t\t-2: FASTA file containing read 2 sequences\n";
	print "\t\t-r: FASTA file containing reference sequences you want read 1 & 2 matched to\n\n";
}