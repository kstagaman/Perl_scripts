#!/usr/bin/perl
# rep_seq_abund.pl
use strict; use warnings;
use Getopt::Long;

my $usage = "\n\trep_seq_abund.pl -c <uclust clusts.fa file> -m <unique seq map file>\n\n";

# defaults
my $help;
my $clust_file;
my $uniq_map;

GetOptions (
	'help!' => \$help,
	'c=s'   => \$clust_file,
	'm=s'   => \$uniq_map,
) or die $usage;

die $usage unless $help or ($clust_file and $uniq_map);

if ($help) {print $usage}

else {

	print "working...\n";

	open UM, "<$uniq_map" or die "\n\tError: cannot open $uniq_map\n\n";
	
	my %uniq_ids;
	my $curr_uniq;

	while (<UM>) {
		if ($_ =~ /^\d/) {
			($curr_uniq) = /^(\d+)/;
			# print "$curr_uniq\n";
		}
		elsif ($_ =~ /^\t\>/) {
			my ($id) = /^\t(\S+)/;
			# print "$id\n";
			push @{$uniq_ids{$curr_uniq}}, $id;
		}
	}
	close UM;


	open CL, "<$clust_file" or die "\n\tError: cannot open $clust_file\n\n";
	
	my ($name) = $clust_file =~ /^(\S+).fa$/;

	my %curr_rep_seq;
	my %otu_count;

	while (<CL>) {

		if ($_ =~ /^\>\d+\|\*\|/) {
			my ($rep_clust) = /^\>(\d+)/;
			my ($uniq_id)   = /\|(\d+):N/;
			my ($combo) = @{$uniq_ids{$uniq_id}}[0] =~ /(V\d{2}:J[mz]\d)/;
			# print "$uniq_ids{$uniq_id}[0]\n";
			# print "$combo\n";

			$curr_rep_seq{clust} = $rep_clust;
			$curr_rep_seq{id}    = $uniq_id;
			$curr_rep_seq{combo} = $combo;

			foreach my $id (@{$uniq_ids{$uniq_id}}) {
				my ($sample) = $id =~ /^\>([mz][abcd]\d{2})/;
				my $smpl_otu = "$sample:$uniq_id:$combo";
				$otu_count{$smpl_otu}++;
			}
		}
		elsif ($_ =~ /^\>$curr_rep_seq{clust}\|\d/) {
			my ($uniq_id) = /\|(\d+):N/;

			foreach my $id (@{$uniq_ids{$uniq_id}}) {
				my ($sample) = $id =~ /^\>([mz][abcd]\d{2})/;
				my $smpl_otu = "$sample:$curr_rep_seq{id}:$curr_rep_seq{combo}";
				$otu_count{$smpl_otu}++;
			}
		}
	}
	close CL;


	open OUT, ">$name.seq_abund_by_smpl.tsv" or die "\n\tError: cannot create $name.seq_abund_by_smpl.tsv\n\n";
	print OUT "sample\tunique_id\tabundance\n";

	my @smpl_otus = sort keys %otu_count;

	foreach my $smpl_otu (@smpl_otus) {
		my ($sample) = $smpl_otu =~ /^([mz][abcd]\d{2}):/;
		my ($otu) = $smpl_otu =~ /^$sample:(\S+)$/;
		print OUT "$sample\t$otu\t$otu_count{$smpl_otu}\n";
	}
}

