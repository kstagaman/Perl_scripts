#!/usr/bin/perl
# seg_assigned_pairs.pl
use strict; use warnings;
use Getopt::Long;

my $usage = "\n\tUsage: seg_assigned_pairs.pl -f <fwd FASTA> -r <rev FASTA> [-o <output PATH> -h -q]\n\n";

# defaults
my $help;
my $quiet;
my $outdir = './';
my $fwd;
my $rev;

GetOptions (
	'help!'  => \$help,
	'quiet!' => \$quiet,
	'o=s'    => \$outdir,
	'f=s'    => \$fwd,
	'r=s'    => \$rev,
) or die $usage;

die $usage unless $help or ($fwd and $rev);
if ($outdir !~ /\/$/) {$outdir = "$outdir\/"}

if ($help) {print $usage}
else {
	# "global" variables
	my %fwd_seqs;
	my %rev_seqs;
	my ($fname) = $fwd =~ /(\S+)\.fa$/;
	my ($rname) = $rev =~ /(\S+)\.fa$/;
	my ($smpl) = $fname =~ /^(\S+)\.fwd/;

	print "$smpl:\n" unless $quiet;

	open FI, "<$fwd" or die "\n\tError: cannot open $fwd\n\n";
	open RI, "<$rev" or die "\n\tError: cannot open $rev\n\n";

	while (<FI>) {

		if ($_ =~ /^\>/) {
			my ($id)  = /^(\S+)_[12]:V/;
			my ($seg) = /:(V\S+)$/;
			my $seq = <FI>;
			chomp $seq;
			$fwd_seqs{$id} = [$seq, $seg];
		}
	}

	while (<RI>) {

		if ($_ =~ /^\>/) {
			my ($id)  = /^(\S+)_[12]:J/;
			my ($seg) = /:(J\S+)$/;
			my $seq = <RI>;
			chomp $seq;
			$rev_seqs{$id} = [$seq, $seg];
		}
	}

	close FI; close RI;
	print "\tin files read\n" unless $quiet;

	my @fwd_ids = sort keys %fwd_seqs;
	
	open FO, ">${outdir}$fname.paired.fa" or die "\n\tError: cannot create $fname.paired.fa\n\n";
	open RO, ">${outdir}$rname.paired.fa" or die "\n\tError: cannot create $rname.paired.fa\n\n";

	my $count = 0;

	foreach my $id (@fwd_ids) {

		if ($rev_seqs{$id}) {
			print FO "$id:$fwd_seqs{$id}[1]\n$fwd_seqs{$id}[0]\n";
			print RO "$id:$rev_seqs{$id}[1]\n$rev_seqs{$id}[0]\n";
			$count++;
		}
	}

	close FO; close RO;

	print "\t$count paired seqs\n" unless $quiet;
}