#!/usr/bin/perl
# compare_cs2pc.pl
use strict; use warnings;
use Getopt::Long;

# Use this script to see if the output from classify.seqs() (in mothur) is similar to my script primer_check.pl

my $usage = "\n\tcompare_cs2pc.pl [options: -h -cs PATH] -pc PATH -i TAXONOMY\n\n";

# defaults
my $help;
my $csdir = './';
my $pcdir;
my $input;

GetOptions (
	'help!' => \$help,
	'cs=s'  => \$csdir,
	'pc=s'  => \$pcdir,
	'i=s'   => \$input,
) or die $usage;

die $usage unless $input and $pcdir or $help;
if ($pcdir !~ /\/$/) {$pcdir = "$pcdir\/"}

# "global" variables
my @pc_files;
my ($sample) = $input =~ /^([mz][abcd]\d{2})/;
my ($read)   = $input =~ /((fa_1|fa_2|rem.fa)).taxonomy$/;
my %pc_assign;
my %cs_assign;
my ($cs_k)   = $input =~ /\.k(\d{1,2})\./;
my ($pc_m)   = $pcdir =~ /_m(\d{1,2})_/;
my ($pc_o)   = $pcdir =~ /_o(\d{1,2})\/$/;


if ($help) {
	help_text();
}
else {

	@pc_files = glob "$pcdir$sample*[fwd|rev]*$read";

	open PCF, "<$pc_files[0]" or die "\n\tError: cannot open $pc_files[0]\n\n";
	open PCR, "<$pc_files[1]" or die "\n\tError: cannot open $pc_files[2]\n\n";

	while (<PCF>) {

		if ($_ =~ /^\>/) {
			my ($seq_num) = /^\>(\d+):N/;
			my ($primer)  = /bp:(\w+):score/;
			my $seq_id = "${seq_num}_$read";
			$pc_assign{$seq_id} = $primer;
		}
	}

	while (<PCR>) {
		
		if ($_ =~ /^\>/) {
			my ($seq_num) = /^\>(\d+):N/;
			my ($primer)  = /bp:(\w+):score/;
			my $seq_id = "${seq_num}_$read";
			$pc_assign{$seq_id} = $primer;
		}
	}

	close PCF; close PCR;
	
	open CS, "<$input" or die "\n\tError: cannot open $input\n\n";

	while (<CS>) {
		my ($seq_num) = /^(\d+):N/;
		my ($primer)  = /(\w+)\(\d+\)\;$/;
		my $seq_id = "${seq_num}_$read";
		$cs_assign{$seq_id} = $primer;
	}

	close CS;

	my @cs_seq_ids = keys %cs_assign;
	my @pc_seq_ids = keys %pc_assign;

	PC_CHK: foreach my $cs_seq_id (@cs_seq_ids) {
		if (defined $pc_assign{$cs_seq_id}) {next PC_CHK}
		else							   {$pc_assign{$cs_seq_id} = "NA"}
	}

	CS_CHK: foreach my $pc_seq_id (@pc_seq_ids) {
		if (defined $cs_assign{$pc_seq_id}) {next CS_CHK}
		else							   {$cs_assign{$pc_seq_id} = "NA"}
	}

	my @final_seq_ids = keys %cs_assign;

	open OUT, ">$sample.$read.k${cs_k}_v_m${pc_m}o$pc_o.comparison.csv" or
	die "\n\tError: cannot create $sample.$read.k${cs_k}_v_m${pc_m}o$pc_o.comparison.csv\n\n";
	
	print OUT "sample,read,seq.id,cs.assign,pc.assign,match,cs.k,pc.m,pc.o\n";
	
	foreach my $seq_id (@final_seq_ids) {
		my $match = 0;
		# print "CS:$cs_assign{$seq_id}\tPC:$pc_assign{$seq_id}\n";
		if ($cs_assign{$seq_id} eq $pc_assign{$seq_id}) {$match = 1}
		print OUT "$sample,$read,$seq_id,$cs_assign{$seq_id},$pc_assign{$seq_id},$match,$cs_k,$pc_m,$pc_o\n";
	}

	close OUT;
}

sub help_text {
	print $usage;
}