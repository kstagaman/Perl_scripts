ls#!/usr/bin/perl
# unique_translations.pl
use strict; use warnings;

die "usage: unique_translations.pl <IgM_translations.fa> <IgZ2_translations.fa>\n" unless @ARGV == 2;

my ($igm_translations) = $ARGV[0];
my ($igz2_translations) = $ARGV[1];

my %igm_id_count = ();
my %igz2_id_count = ();

open IGM, "<$igm_translations" or die "Error: cannot open IgM translation file\n";
open IGMTSV, ">all_IgM_translations.tsv";

while (my $line = <IGM>) {

	if ($line =~ /^\>/) {
		my ($id) = $line =~ /^\>(.+)/;
					
		if (exists $igm_id_count{$id}) {$igm_id_count{$id}++}
		else					       {$igm_id_count{$id} = 1}	
	}
	
	chomp $line;
	print IGMTSV "$line\t";
	$line = <IGM>;
	print IGMTSV "$line";
}

close IGM; close IGMTSV;

my @igm_ids = keys %igm_id_count;
	
my @unique_igm_ids = ();
my @nonunique_igm_ids = ();

foreach my $igm_id (@igm_ids) {
	
	if ($igm_id_count{$igm_id} == 1) {push (@unique_igm_ids, $igm_id)}
	else							 {push (@nonunique_igm_ids, $igm_id)}
}

my $umtotal = @unique_igm_ids;
my $nmtotal = @nonunique_igm_ids;
my $umcount = 1;
my $nmcount = 1;

system("grep $unique_igm_ids[0] all_IgM_translations.tsv > unique_IgM_translations.tsv");
for (my $i = 1; $i < @unique_igm_ids; $i++) {
	system("grep $unique_igm_ids[$i] all_IgM_translations.tsv >> unique_IgM_translations.tsv");
	$umcount++;
	if ($umcount % 100 == 0) {print "$umcount of $umtotal unique IgM\n"}
}


system("grep $nonunique_igm_ids[0] all_IgM_translations.tsv > nonunique_IgM_translations.tsv");
for (my $i = 1; $i < @nonunique_igm_ids; $i++) {
	system("grep $nonunique_igm_ids[$i] all_IgM_translations.tsv >> nonunique_IgM_translations.tsv");
	$nmcount++;
	if ($nmcount % 100 == 0) {print "$nmcount of $nmtotal nonunique IgM\n"}
}

#################################################	

open IGZ2, "<$igz2_translations" or die "Error: cannot open IgZ2 translation file\n";
open IGZ2TSV, ">all_IgZ2_translations.tsv";

while (my $line = <IGZ2>) {

	if ($line =~ /^\>/) {
		my ($id) = $line =~ /^\>(.+)/;
					
		if (exists $igz2_id_count{$id}) {$igz2_id_count{$id}++}
		else					        {$igz2_id_count{$id} = 1}	
	}
	chomp $line;
	print IGZ2TSV "$line\t";
	$line = <IGZ2>;
	print IGZ2TSV "$line";
}

close IGZ2; close IGZ2TSV;

my @igz2_ids = keys %igz2_id_count;
	
my @unique_igz2_ids = ();
my @nonunique_igz2_ids = ();

foreach my $igz2_id (@igz2_ids) {
	
	if ($igz2_id_count{$igz2_id} == 1) {push (@unique_igz2_ids, $igz2_id)}
	else							  {push (@nonunique_igz2_ids, $igz2_id)}
}

my $uz2total = @unique_igz2_ids;
my $nz2total = @nonunique_igz2_ids;
my $uz2count = 1;
my $nz2count = 1;

system("grep $unique_igz2_ids[0] all_IgZ2_translations.tsv > unique_IgZ2_translations.tsv");
for (my $i = 1; $i < @unique_igz2_ids; $i++) {
	system("grep $unique_igz2_ids[$i] all_IgZ2_translations.tsv >> unique_IgZ2_translations.tsv");
	$uz2count++;
	if ($uz2count % 100 == 0) {print "$uz2count of $uz2total unique IgZ2\n"}
}


system("grep $nonunique_igz2_ids[0] all_IgZ2_translations.tsv > nonunique_IgZ2_translations.tsv");
for (my $i = 1; $i < @nonunique_igz2_ids; $i++) {
	system("grep $nonunique_igz2_ids[$i] all_IgZ2_translations.tsv >> nonunique_IgZ2_translations.tsv");
	$nz2count++;
	if ($nz2count % 100 == 0) {print "$nz2count of $nz2total nonunique IgZ2\n"}
}
