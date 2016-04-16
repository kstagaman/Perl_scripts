#!/usr/bin/perl
# match_fwd_rev_j_hit.pl
use warnings; use strict;
use Getopt::Long;

# use this script to see if the corresponding fwd and rev reads that have been assigned a Jseg match in their assignment

my $usage = "\n\tUsage: match_fwd_rev_j_hit.pl [-h -o PATH] -f <fwd FA> -r <rev FA>\n\n";

# defaults
my $fwd;
my $rev;
my $help;
my $outdir = './';

GetOptions (
	'help!' => \$help,
	'o=s'   => \$outdir,
	'r=s'   => \$rev,
	'f=s'   => \$fwd,
) or die $usage;

die $usage unless $help or ($fwd and $rev);
if ($outdir !~ /\/$/) {$outdir = "$outdir\/"}

if ($help) {help_txt()} 
else {
	# global variables
	my %fwd_js;
	my %rev_js;
	my ($sample) = $fwd =~ /([mz][abcd]\d{2}_*\d*)\./;


	open FWD, "<$fwd" or die "\n\tError: cannot open $fwd\n\n";

	while (<FWD>) {
		if ($_ =~ /^\>/) {
			my ($fwd_id) = /^\>(\w+)_[12]:/;
			my ($fwd_jeval) = /(J[mz]\d\(.+\))/;
			$fwd_js{$fwd_id} = $fwd_jeval;
		}
	}
	close FWD;

	open REV, "<$rev" or die "\n\tError: cannot open $rev\n\n";

	while (<REV>) {
		if ($_ =~ /^\>/) {
			my ($rev_id) = /^\>(\w+)_[12]:/;
			my ($rev_jeval) = /(J[mz]\d\(.+\))/;
			$rev_js{$rev_id} = $rev_jeval;
		}
	}
	close REV;

	my @fwd_ids = sort keys %fwd_js;
	my @rev_ids = sort keys %rev_js;

	open OUT, ">$sample.fr_jmatches.txt" or die "\n\tError: cannot create fwd_rev_j_matches.txt\n\n";
	print OUT "sample\tid\tfwd.j\tfwd.eval\trev.j\trev.eval\tmatch\n";

	my $num_matches = 0;

	foreach my $fwd_id (@fwd_ids) {
		if (grep /$fwd_id/, @rev_ids) {
			my $match = 0;
			my ($fwd_j) = $fwd_js{$fwd_id} =~ /(J[mz]\d)\(/;
			my ($rev_j) = $rev_js{$fwd_id} =~ /(J[mz]\d)\(/;
			my ($fwd_eval) = $fwd_js{$fwd_id} =~ /\((.+)\)/;
			my ($rev_eval) = $rev_js{$fwd_id} =~ /\((.+)\)/;

			if ($fwd_j eq $rev_j) {
				$match = 1;
				$num_matches++;
			}

			print OUT "$sample\t$fwd_id\t$fwd_j\t$fwd_eval\t$rev_j\t$rev_eval\t$match\n";

		}
	}
}


sub help_txt {
	print $usage; 
}