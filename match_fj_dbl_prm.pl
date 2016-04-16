#!/usr/bin/perl
# match_fj_dbl_prm.pl
use warnings; use strict;

# Use this script to see if there's overlap with sequences that have both primers, and ones with the fwd primer that blasted to a J-seg
# Run this script in a directory containing *fwd.fa, *rev.fa, *fwd.j.fa, *fwd.dbl.fa, *rev.dbl.fa files

my $usage = "\n\tUsage: match_fj_dbl_prm.pl <m/z>\n\n";

die $usage unless $ARGV[0] =~ /^[mz]$/;

my @all_files = glob "$ARGV[0]*.fa";
die "\n\tError: no files present\n\n" unless @all_files > 0;

my %smpl_names;

for my $file (@all_files) {
	my ($smpl) = $file =~ /^($ARGV[0]\w+)\./;
	$smpl_names{$smpl}++;
}

open OUT, ">all_ig$ARGV[0].sterile_trx_stats.txt" or die "\n\nError: cannot create all_ig$ARGV[0].sterile_trx_stats.txt\n\n";
print OUT "sample\tfwd.tot\trev.tot\tfwd.ster.tot\trev.ster.tot\t\tfwd.j.tot\tfwd.dbl.tot\tshared.tot\n";

my @samples = sort keys %smpl_names;

foreach my $smpl (@samples) {
	print "$smpl:\n";
	my $fwd_total = `grep -c "^>" $smpl.fwd.fa`;

	my $rev_total = `grep -c "^>" $smpl.rev.fa`;

	my $fwd_dbl_total = 0;
	if (grep /$smpl.fwd.dbl.fa/, glob "$smpl*") {$fwd_dbl_total = `grep -c "^>" $smpl.fwd.dbl.fa`}

	my $rev_dbl_total = 0;
	if (grep /$smpl.rev.dbl.fa/, glob "$smpl*") {$rev_dbl_total = `grep -c "^>" $smpl.rev.dbl.fa`}

	my $fwd_j_total = 0;
	if (grep /$smpl.fwd.j.fa/, glob "$smpl*") {$fwd_j_total = `grep -c "^>" $smpl.fwd.j.fa`}

	chomp($fwd_total, $rev_total, $fwd_dbl_total, $rev_dbl_total, $fwd_j_total);

	my @fwd_dbl_ids;
	my @fwd_j_ids;
	open DBL, "<$smpl.fwd.dbl.fa" or goto JIDS;

	while (<DBL>) {
		if ($_ =~ /^\>/) {
			my ($id) = /^\>(\w+)/;
			push @fwd_dbl_ids, $id;
		}
	}
	close DBL;

	JIDS:
	open JFA, "<$smpl.fwd.j.fa" or goto MATCHING;

	while (<JFA>) {
		if ($_ =~ /^\>/) {
			my ($id) = /^\>(\w+):/;
			push @fwd_j_ids, $id;
		}
	}
	close JFA;

	MATCHING:
	print "\tmatching shared ...";
	my $shared_fwd_ids = 0;
	unless (@fwd_dbl_ids == 0 or @fwd_j_ids == 0) {
		foreach my $dbl_id (@fwd_dbl_ids) {
			if (grep /$dbl_id/, @fwd_j_ids) {
				$shared_fwd_ids++;
			}
		}
	}
	print " done\n";
	my $fwd_ster_tot = ($fwd_j_total + $fwd_dbl_total) - $shared_fwd_ids;

	print OUT "$smpl\t$fwd_total\t$rev_total\t$fwd_ster_tot\t$rev_dbl_total\t\t$fwd_j_total\t$fwd_dbl_total\t$shared_fwd_ids\n";

}

close OUT;

