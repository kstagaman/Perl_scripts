#!/usr/bin/perl
# blat_output.pl
use strict; use warnings;
use Getopt::Long;

# use this script with blat output in blast8 format (BLAST's tab format)

my $usage = "\n\tblat_output.pl [-h -q -d <output path>] -i <blast8 file> -p <genomic positions file>\n\n";

# defaults
my $help;
my $quiet;
my $outdir = './';
my $infile;
my $positions;

GetOptions (
	'help!'  => \$help,
	'quiet!' => \$quiet,
	'd=s'    => \$outdir,
	'i=s'    => \$infile,
	'p=s'    => \$positions,
) or die $usage;

die $usage unless $help or ($infile and $positions);
if ($outdir !~ /\/$/) {$outdir = "$outdir\/"}

if ($help) {help_text()}
else {
	# 'global' variables
	my ($name) = $infile =~ /(\S+)\.blast8$/;
	$|++; print "$name: " unless $quiet;

	my %segByStart;
	my @seg_starts;
	my %smpl_assigns;
	

	open POS, "<$positions" or die "\n\tError: cannot open $positions\n\n";

	$_ = <POS>;
	while (<POS>) {
		my ($seg)  = /^(\S+)\t/;
		my ($label) = /^$seg\t(\S+)\t/;
		my ($start) = /\t(\d+)\t\d+$/;
		my ($end)   = /\t(\d+)$/;
		
		$segByStart{$start} = {seg => $seg, label => $label, end => $end};
		push @seg_starts, $start;
	}
	close POS;

	open INF, "<$infile" or die "\n\tError: cannot open $infile\n\n";
	open BTO, ">$name.blatout" or die "\n\tError: cannot create $name.blatout\n\n";

	print BTO "smpl\tseg\tlabel\teval\twithin.seg\tseq.len\tmatch.len\tquery.start\tquery.stop\tseg.start\tseg.stop\n";

	while (<INF>) {
		my ($smpl)    = /^(\S+)\t/;
		my ($seq_len) = /^$smpl\t\S+\t[\d\.]+\t(\d+)\t/;
		my ($start)   = /\t(\d+)\t\d+\t[\de\.\-\+]+\t[\d\.]+$/;
		my ($stop)    = /$start\t(\d+)\t/;
		my ($eval)    = /$start\t$stop\t([\de\.\-\+]+)\t/;
		my $match_start = $start;
		my $match_stop  = $stop;

		if ($start > $stop) {
			$match_start = $stop;
			$match_stop  = $start;
		}

		foreach my $seg_start (@seg_starts) {

			if ($match_start >= $seg_start and $match_start <= $segByStart{$seg_start}->{end}) {
				my $end_diff = $segByStart{$seg_start}->{end} - $match_stop;
				my $within = 'yes';
				if ($end_diff < 0) {$within = 'no'}
				my $match_len = $match_stop - $match_start;

				print BTO "$smpl\t$segByStart{$seg_start}->{seg}\t$segByStart{$seg_start}->{label}\t$eval\t$within\t$seq_len\t$match_len\t$match_start\t$match_stop\t$seg_start\t$segByStart{$seg_start}->{end}\n";
			}
		}
	}
	close INF; close BTO;
	$|++; print "blatout created..." unless $quiet;

	open BTO, "<$name.blatout" or die "\n\tError: cannot open $name.blatout\n\n";

	$_ = <BTO>;
	my $curr_smpl = 0;
	while (<BTO>) {
		my ($smpl) = /^(\w+)\t/;
		if ($smpl ne $curr_smpl) {$curr_smpl = $smpl};
		my ($seg)    = /^$smpl\t(\S+)\t/;
		my ($assign) = /^$smpl\t$seg\t(\S+)\t/;
		my ($eval)   = /^$smpl\t\S+\t$assign\t([e\d\.\-\+]+)\t/;
		my $type = substr ($seg, 0, 4);
		push @{$smpl_assigns{$curr_smpl}}, {type => $type, assign => $assign, e_val => $eval}; 
	}
	close BTO;
	$|++; print "assignments retrieved..." unless $quiet;

	my @smpls = sort keys %smpl_assigns;

	open TXT, ">$name.top_assign.txt" or die "\n\tError: cannot create $name.top_assign.txt\n\n";

	foreach my $smpl (@smpls) {
		my @prev_types;
		my @prev_evals;

		for (my $i=0; $i < @{$smpl_assigns{$smpl}}; $i++) {
			my $eval   = $smpl_assigns{$smpl}[$i]->{e_val};
			my $type   = $smpl_assigns{$smpl}[$i]->{type};
			my $assign = $smpl_assigns{$smpl}[$i]->{assign};


			my @test = grep (/$type/, @prev_types);
		
			if (@test == 0) {
				print TXT "$smpl\t$assign\t$eval\n";
				push @prev_types, $type;
				push @prev_evals, $eval;
			}
			elsif (grep /$eval/, @prev_evals) {
				print TXT "$smpl\t$assign\t$eval\n";
			}
		}
		print TXT "\n";
	}
	close TXT;
	print "top assignments recorded\n" unless $quiet;
}

sub help_txt {
	print $usage;
}