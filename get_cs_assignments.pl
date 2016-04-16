#!/usr/bin/perl
# get_cs_assignments.pl
use strict; use warnings;
use Getopt::Long;

# Use this script on a FASTA file to get the assignments given by classify.seqs() in mothur.

my $usage = "\n\tUsage: get_cs_assignments.pl [-d <PATH to CS directory>] -i <FASTA file> [-h]\n\n";

# defaults
my $help;
my $csdir ='./';
my $infile;

GetOptions (
	'help!' => \$help,
	'd=s'   => \$csdir,
	'i=s'   => \$infile,
) or die $usage;

die $usage unless $infile or $help;
if ($csdir !~/\/$/) {$csdir = "$csdir\/"}

# "global" variables
my ($filename)  = $infile =~ /^([mz][abcd]\d{2}\.\S+)\.(fa_1|fa_2|rem.fa)$/;
my ($extension) = $infile =~ /\.((fa_1|fa_2|rem.fa))$/;
my %cs_assigns;

if ($help) {
	help_text();
}
else {
	my $csfile = glob "$csdir$filename*$extension.taxonomy";
	open CS, "<$csfile" or die "\n\tError: cannot open $csfile\n\n";

	while (<CS>) {
		my ($id)     = /^(\S+)\s/;
		my ($primer) = /(\w+)\(\d{1,3}\)\;$/;
		$cs_assigns{$id} = $primer;
		# print "$id: $primer\n";
	}

	close CS;

	open FA, "<$infile" or die "\n\tError: cannot open $infile\n\n";
	open FWD, ">$csdir$filename.fwd.$extension" or die "\n\tError: cannot create $csdir$filename.fwd.$extension\n\n";
	open REV, ">$csdir$filename.rev.$extension" or die "\n\tError: cannot create $csdir$filename.rev.$extension\n\n";

	while (<FA>) {
		if ($_ =~ /^\>/) {
			my ($id)  = /^\>(\S+)/;
			my $seq = <FA>;
			chomp $seq;
			# print "$id: $seq\n";

			if ($cs_assigns{$id} =~ /^f/) {
				print FWD "\>$id:$cs_assigns{$id}\n$seq\n";
			} else {
				print REV "\>$id:$cs_assigns{$id}\n$seq\n";
			}
		}
	}

	close FA; close FWD; close REV;
}

sub help_text {
	print "$usage";
}