#!/usr/bin/perl
# match_vquest_assignments.pl
use strict; use warnings;
use Getopt::Long;

# use this script to match sequences in a FASTA to UNIQUE sequences already assigned a segment by VQUEST

## start with good.ids file
## use glob to batch files

my $usage = "\n\tmatch_vquest_assignments [-h -o] -p <FILE MATCHING PATTERN> -v <VQUEST SUMMARY FILE>\n\n";

# defaults
my $help;
my $outdir = './';
my $pattern;
my $vquest_file;

GetOptions (
	'help!' => \$help,
	'o=s'   => \$outdir,
	'p=s'   => \$pattern,
	'v=s'   => \$vquest_file,
) or die $usage;

die $usage unless $help or ($pattern and $vquest_file);
if ($outdir !~ /\//) {$outdir = "$outdir\/"}

if ($help) {
	print $usage;
	print "\t# use this script to match sequences in a FASTA to UNIQUE sequences already assigned a segment by VQUEST\n"
}
else {
	# global variables
	my @infiles = glob $pattern;
	my %vquest_assignments;


	open VQF, "<$vquest_file" or die "\n\tError: cannot open $vquest_file\n\n";
	while (<VQF>) {
		if ($_ =~ /^\d+/) {
			my ($seq) = /([ACGTN]+)\s*$/i;
			$seq = uc $seq;
			my ($seg) = /(IGH[VDJ]\d+\-\d+)/;
			if ($seg) {$vquest_assignments{$seq} = $seg}
			else {$vquest_assignments{$seq} = "No_results"}
		}
	}
	close VQF;
	$|++;
	print "V-QUEST assignments grabbed\n";

	open OTX, ">${outdir}v_by_sample_results.txt" or die "\n\tError: cannot create ${outdir}v_by_sample_results.txt\n\n";
	foreach my $infile (@infiles) {
		my ($filename) = $infile =~ /(.+)\.fas*t*a*$/;
		my ($smpl) = $infile =~ /fwd\.([ACGT]+)\.fa/i;
		my %smpl_seg_counts;
		my @segs;

		$|++;
		print "$infile...";

		open INF, "<$infile" or die "\n\tError: cannot open $infile\n\n";
		open OFA, ">${outdir}$filename.seg_assigned.fa" or die "\n\tError: cannot create ${outdir}filename.seg_assigned.fa\n\n";

		while (<INF>) {
			if ($_ =~ /^>/) {
				my $seq_id = $_;
				my $seq = <INF>;
				chomp $seq_id; chomp $seq;
				$seq = uc $seq;

				if (exists $vquest_assignments{$seq}) {
					print OFA "$seq_id:$vquest_assignments{$seq}\n$seq\n";
					$smpl_seg_counts{$vquest_assignments{$seq}}++;
				}
				else {
					print OFA "$seq_id:No_results\n$seq\n";
				}
			}
		}
		close INF; close OFA;

		@segs = sort {$smpl_seg_counts{$b} <=> $smpl_seg_counts{$a}} keys %smpl_seg_counts;
		foreach my $seg (@segs) {
			print OTX "$seg\|$smpl_seg_counts{$seg}\|$smpl\n";
		}
		$|++;
		print "done\n";
	}
	close OTX;
}