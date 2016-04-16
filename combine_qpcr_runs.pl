#!/usr/bin/perl
# combine_qpcr_runs.pl
use strict; use warnings;

# use this script to take data from the StepOne (Plus) qPCR machine from mulitple runs, and combine the appropriate
# columns into one file for analysis of the whole group of runs.

my $usage = "\n\tcombine_qpcr_runs.pl [-h] <tab-delim file 1> <tab-delim file 2> [... <tab-delim file n>]\n\n";

die $usage unless @ARGV >= 1;

if ($ARGV[0] =~ /^-he*l*p*/) {help_txt()}
else {
	my @files = @ARGV;
	my $group = 1;
	my %sigm_cts;
	my %sdha_cts;
	my %elf1b_cts;

	foreach my $file (@files) {
		open IN, "<$file" or die "\n\tError: cannot open $file\n\n";

		while (<IN>) {

			if ($_ =~ /^[A-Z]\d{1,2}\t/) {
				my ($sample) = /^[A-Z]\d{1,2}\t(\w*)\t/;
				next if !$sample;
				my ($target) = /\t$sample\t([\w\-]+)\t/;
				my ($ct)     = /\t$sample\t$target\t[A-Z]+\t[A-Z]+\t\w+\t[\d\.]*\t[\d\.]*\t[\d\.]*\t([\d\.]+)\t/;
				my $smpl_grp = "$sample:$group";

				if ($target =~ /Cu3SD-CtailS/) {
					push @{$sigm_cts{$smpl_grp}}, $ct;
				}
				elsif ($target =~ /SDHA/) {
					$sdha_cts{$smpl_grp} = $ct;
				}
				elsif ($target =~ /ElF1B/) {
					$elf1b_cts{$smpl_grp} = $ct;
				}
			}
		}
		close IN;
		$group++;
	}

	my @smpl_grps = sort keys %sigm_cts;
	my %timepoints = ("c2" => 10, "c3" => 21, "c4" => 28, "c5" => 35, "c6" => 75);

	my $ref_sigm_ct1 = $sigm_cts{$smpl_grps[0]}[0];
	my $ref_sigm_ct2 = $sigm_cts{$smpl_grps[0]}[1];
	my $ref_sdha_ct  = $sdha_cts{$smpl_grps[0]};
	my $ref_elf1b_ct = $elf1b_cts{$smpl_grps[0]};

	my $ref_dct1 = (($ref_sigm_ct1 - $ref_sdha_ct) + ($ref_sigm_ct1 - $ref_elf1b_ct)) / 2;
	my $ref_dct2 = (($ref_sigm_ct2 - $ref_sdha_ct) + ($ref_sigm_ct2 - $ref_elf1b_ct)) / 2;
	my $ref_dct_mean = ($ref_dct1 + $ref_dct2) / 2;

	open RAW, ">combined_runs.txt" or die "\n\tError: cannot create combined_runs.txt\n\n";
	print RAW "sample\tgroup\tage\ttank\ttarget\tCt\tdCt\tdCt.mean\tdCt.sd\tddCt\trq\n";

	open PLT, ">combined_runs_smpl_rq.txt" or die "\n\tError:cannot create combined_runs_smpl_rq.txt\n\n";
	print PLT "sample\tgroup\tage\ttank\trq\trq.low\trq.hi\n";

	foreach my $smpl_grp (@smpl_grps) {
		my ($sample) = $smpl_grp =~ /^(\w+):/;
		my ($group)  = $smpl_grp =~ /:(\d+)/;
		my ($tp) = $sample =~ /^(c\d)[ABCD]/;
		my ($tank) = $sample =~ /([ABCD])\d{2}$/;
		my $sigm_ct1 = $sigm_cts{$smpl_grp}[0];
		my $sigm_ct2 = $sigm_cts{$smpl_grp}[1];
		my $sigm_ct_mean = ($sigm_ct1 + $sigm_ct2) / 2;
		my $sigm_ct_sd = sqrt((($sigm_ct1 - $sigm_ct_mean)**2 + ($sigm_ct2 - $sigm_ct_mean)**2) / 1);
		my $sdha_ct  = $sdha_cts{$smpl_grp};
		my $elf1b_ct = $elf1b_cts{$smpl_grp};

		my $dct1 = (($sigm_ct1 - $sdha_ct) + ($sigm_ct1 - $elf1b_ct)) / 2;
		my $dct2 = (($sigm_ct2 - $sdha_ct) + ($sigm_ct2 - $elf1b_ct)) / 2;
		my $dct_mean = ($dct1 + $dct2) / 2;
		my $ddct = $dct_mean - $ref_dct_mean;
		my $rq = 2**(-$ddct);
		my $rq_low = 2**(-$ddct - $sigm_ct_sd);
		my $rq_hi  = 2**(-$ddct + $sigm_ct_sd);

		print RAW "$sample\t$group\t$timepoints{$tp}\t$tank\tCu3SD-CtailS\t$sigm_ct1\t$dct1\t$dct_mean\t$sigm_ct_sd\t$ddct\t$rq\n";
		print RAW "$sample\t$group\t$timepoints{$tp}\t$tank\tCu3SD-CtailS\t$sigm_ct2\t$dct2\n";
		print RAW "$sample\t$group\t$timepoints{$tp}\t$tank\tElF1B\t$elf1b_ct\n";
		print RAW "$sample\t$group\t$timepoints{$tp}\t$tank\tSDHA\t$sdha_ct\n";

		print PLT "$sample\t$group\t$timepoints{$tp}\t$tank\t$rq\t$rq_low\t$rq_hi\n";
	}
	close RAW; close PLT;
}

sub help_txt {
	print $usage;
}