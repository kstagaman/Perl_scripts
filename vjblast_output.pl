#!/usr/bin/perl
# vjblast_output.pl
use strict; use warnings;
use Getopt::Long;

# Use this script aftering blasting locally to the V or J[mz] databases 
# to get the seg assignment for a sequence.

my $usage = "\n\tUsage: vjblast_output.pl [options: -h -d <PATH to fasta files>] -i <.[vj]blast file>\n\n";

# defaults
my $help;
my $fadir = './';
my $infile;

GetOptions (
	'help!' => \$help,
	'd=s'   => \$fadir,
	'i=s'   => \$infile,
) or die $usage;

die $usage unless $infile or $help;
if ($fadir !~ /\/$/) {$fadir = "$fadir\/"}

if ($help) {
	help_text();
}
else {
	# "global" variables
	my %blast_results;
	my ($fasta)     = $infile =~ /^(\S+)\.[vj][mz]*\w*blast/;
	my ($filename)  = $fasta  =~ /(.+)\.(rem\.fa|fa_[12]|fa)$/;
	my ($extension) = $fasta  =~ /\.((rem\.fa|fa_[12]|fa))$/;

	# print "$fasta\t$filename\t$extension\n";
	
	open BLAST, "<$infile" or die "\n\tError: cannot open $infile\n\n";

	while (<BLAST>) {
		if ($_ =~ /^Query=/) {
			my ($id) = /Query= (\S+)$/;
			# print "$id\n";

			until ($_ =~ /^\s+[VJ][mz]*\d{1,2}/ or $_ =~ /^\*{5} No hits found/) {$_ = <BLAST>}

			if ($_ =~ /No hits found/) {
				$blast_results{$id} = ["no_hit"];
			} else {
				my ($best_match) = /([VJ][mz]*\d{1,2})/;
				my ($evalue)     = /((\d\.\d{1,3}|\de\-\d{2}))\s*$/;
				# print "$best_match\t$evalue\n";
				chomp $evalue;
				$blast_results{$id} = [$best_match, $evalue];
			}
		}
	}
	# my @ids = sort keys %blast_results;
	# print "@ids\n";
	close BLAST;

	open FA, "<${fadir}$fasta" or die "\n\tError: cannot open ${fadir}$fasta\n\n";

	if ($infile =~ /\.v\w*blast$/) {
		open OUT, ">${fadir}$filename.v.$extension" or die "\n\tError: cannot create ${fadir}$filename.v.$extension\n\n";
	}
	elsif ($infile =~ /\.j[mz]*\w*blast$/) {
		open OUT, ">${fadir}$filename.j.$extension" or die "\n\tError: cannot create ${fadir}$filename.j.$extension\n\n";
	}

	while (<FA>) {

		if ($_ =~ /^\>/) {
			my ($id) = /^\>(\S+)/;
			my $seq = <FA>;
			chomp $seq;
			# print "$id\t$blast_results{$id}[0]\n";

			if ($blast_results{$id} and $blast_results{$id}[0] ne "no_hit") {
				print OUT "\>$id:$blast_results{$id}[0]\($blast_results{$id}[1]\)\n$seq\n";
			}
		
		}
	}

	close FA; close OUT;

}




sub help_text {
	print $usage;
	print "\t\t-h: this helpful help screen\n";
	print "\t\t-d: path to directory containing blasted fasta files, default is current directory\n";
	print "\t\t-i: input file, in standard BLAST format\n\n";

}