#!/usr/bin/perl
# level_seqs.pl
use strict; use warnings;
use Getopt::Long;

# use this script to make sequences equal in length by chopping off sequences from the front or back end.s

my $usage = "\n\tlevel_seqs.pl [-h -o <out directory PATH> -f <num bases> -b <num bases>] -i <FASTA file>\n\n";

# defaults
my $help;
my $outdir = './';
my $frnt_bp = 0;
my $back_bp = 0;
my $infile;

GetOptions(
	'help!' => \$help,
	'o=s'   => \$outdir,
	'f=i'   => \$frnt_bp,
	'e=i'   => \$back_bp,
	'i=s'   => \$infile,
) or die $usage;

die $usage unless $help or $infile;
if ($outdir !~ /\/$/) {$outdir = "$outdir\/"}

if ($frnt_bp==0 and $back_bp==0 and !$help) {
	print $usage;
	print "\tA number of bases from the front (-f) and/or back (-b) end of the sequences needs to be specified\n\n";
	die;
}

if ($frnt_bp > 0 and $back_bp > 0) {
	print $usage;
	print "\tYou cannot specify to keep bases from both ends\n\n";
	die;
}

if ($help) {
	print $usage;
	print "\t\t-h: the helpful help screen\n";
	print "\t\t-o: output directory, default is current (./)\n";
	print "\t\t-f: number of bases to keep from the front end of the sequences, default = 0\n";
	print "\t\t-b: number of bases to keep from the back end of the sequences, default = 0\n";
	print "\t\t-i: input FASTA file containing sequences\n";
}
else {
	# global variables
	my ($filename) = $infile =~ /(.+)\.fa$/;
	my $frnt_index = $frnt_bp - 1;
	my $back_index = -1 * $back_bp;
	my $in_count = 0;
	my $out_count = 0;

	open INF, "<$infile" or die "\n\tError: cannot open $infile\n\n";

	if ($frnt_bp > 0) {
		open OUT, ">${outdir}$filename.frnt$frnt_bp.fa" or die "\n\tError: cannot create ${outdir}$filename.frnt$frnt_bp.fa\n\n";

		LINE: while (<INF>) {
			if ($_ =~ /^\>/) {
				$in_count++;
				my $hdr = $_;
				my $seq = <INF>;

				chomp $hdr;
				chomp $seq;

				my $seq_len = length $seq;

				if ($frnt_bp > $seq_len) {
					print STDERR "Sequence $hdr is shorter than number of bases required and was skipped\n";
					next LINE;
				}

				my $trimmed_seq = substr($seq, 0, $frnt_index);
				my $removed = $seq_len - length($trimmed_seq);

				print OUT "$hdr:$removed off back\n$trimmed_seq\n";
				$out_count++;
			}
		}
	}
	else {
		open OUT, ">${outdir}$filename.back$back_bp.fa" or die "\n\tError: cannot create ${outdir}$filename.back$back_bp.fa\n\n";

		LINE: while (<INF>) {
			if ($_ =~ /^\>/) {
				$in_count++;
				my $hdr = $_;
				my $seq = <INF>;

				chomp $hdr;
				chomp $seq;

				my $seq_len = length $seq;

				if ($back_bp > $seq_len) {
					print STDERR "Sequence $hdr is shorter than number of bases required and was skipped\n";
					next LINE;
				}

				my $trimmed_seq = substr($seq, $back_index);
				my $removed = $seq_len - length($trimmed_seq);

				print OUT "$hdr:$removed off front\n$trimmed_seq\n";
				$out_count++;
			}
		}
	}
	close INF; close OUT;
	print "\n\t$in_count sequences read\n";
	print "\t$out_count sequences trimmed\n\n";
}