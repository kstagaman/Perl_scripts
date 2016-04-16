#!/usr/bin/perl
# ig_and_primer_matched_pairs.pl
use strict; use warnings;
use Getopt::Long;

my $usage = "\n\tUsage: ig_and_primer_matched_pairs.pl [options -h -q] -s <sample label>\n\n";

# defaults
my $help;
my $quiet;
my $sample;

GetOptions (
	'help!'  => \$help,
	'quiet!' => \$quiet,
	's=s'    => \$sample,
) or die $usage;

die $usage unless $sample or $help;

if ($help) {help_text()}
else {

	my $fwd1fa = glob "$sample*1*bfwd*fa";
	my $fwd2fa = glob "$sample*2*bfwd*fa";
	my $rev1fa = glob "$sample*1*brev*fa";
	my $rev2fa = glob "$sample*2*brev*fa";

	my %fwd_reads;
	my %rev_reads;

	open F1IN, "<$fwd1fa" or die "\n\tError: cannot open $fwd1fa\n\n";
	open F2IN, "<$fwd2fa" or die "\n\tError: cannot open $fwd2fa\n\n";
	open R1IN, "<$rev1fa" or die "\n\tError: cannot open $rev1fa\n\n";
	open R2IN, "<$rev2fa" or die "\n\tError: cannot open $rev2fa\n\n";

	while (<F1IN>) {

		if ($_ =~ /^\>/) {
			my ($loc_id) = /^\>(\w+)_1:/;
			my ($seq_id) = /^\>(.+)/;
			my $seq = <F1IN>;
			chomp $seq;
			if ($fwd_reads{$loc_id}) {
				$fwd_reads{$loc_id}="NA";
			} else {
				$fwd_reads{$loc_id} = [$seq_id, $seq];
			}
			
		}
	}
	close F1IN;
	# print "$fwd1fa closed\n";

	while (<F2IN>) {
		
		if ($_ =~ /^\>/) {
			my ($loc_id) = /^\>(\w+)_2:/;
			my ($seq_id) = /^\>(.+)/;
			my $seq = <F2IN>;
			chomp $seq;
			if ($fwd_reads{$loc_id}) {
				$fwd_reads{$loc_id}="NA";
			} else {
				$fwd_reads{$loc_id} = [$seq_id, $seq];
			}
			
		}
	}
	close F2IN;
	# print "$fwd2fa closed\n";

	while (<R1IN>) {
		
		if ($_ =~ /^\>/) {
			my ($loc_id) = /^\>(\w+)_1:/;
			my ($seq_id) = /^\>(.+)/;
			my $seq = <R1IN>;
			chomp $seq;
			if ($rev_reads{$loc_id}) {
				$rev_reads{$loc_id}="NA";
			} else {
				$rev_reads{$loc_id} = [$seq_id, $seq];
			}
			
		}
	}
	close R1IN;
	# print "$rev1fa closed\n";

	while (<R2IN>) {
		
		if ($_ =~ /^\>/) {
			my ($loc_id) = /^\>(\w+)_2:/;
			my ($seq_id) = /^\>(.+)/;
			my $seq = <R2IN>;
			chomp $seq;
			if ($rev_reads{$loc_id}) {
				$rev_reads{$loc_id}="NA";
			} else {
				$rev_reads{$loc_id} = [$seq_id, $seq];
			}
			
		}
	}
	close R2IN;
	# print "$rev2fa closed\n";

	my @shared_ids;
	my @fwd_loc_ids = keys %fwd_reads;
	my @rev_loc_ids = keys %rev_reads;
	my $num_shared = 0;

	foreach my $fwd_loc_id (@fwd_loc_ids) {

		if (grep /$fwd_loc_id/, @rev_loc_ids) {
			push @shared_ids, $fwd_loc_id;
			$num_shared++;
		}

		print "\r$num_shared shared seqs..." unless $quiet;
	}
	print "\n";

	open FOUT, ">$sample.fwd.p.fa" or die "\n\tError: cannot create $sample.fwd.p.fa\n\n";
	open ROUT, ">$sample.rev.p.fa" or die "\n\tError: cannot create $sample.rev.p.fa\n\n";

	foreach my $shared_id (@shared_ids) {
		print FOUT "\>$fwd_reads{$shared_id}[0]\n$fwd_reads{$shared_id}[1]\n";
		print ROUT "\>$rev_reads{$shared_id}[0]\n$rev_reads{$shared_id}[1]\n";
	}

	close FOUT; close ROUT;
}

sub help_text {
	print $usage;
	print "\t\t-h: this screen\n";
	print "\t\t-q: quiet, no output to STDOUT\n";
	print "\t\t-s: four letter sample id\n\n";
}

