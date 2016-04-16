#!/usr/bin/perl
# comboblast_output.pl
use strict; use warnings;
use Getopt::Long;

# Use this script aftering blasting locally to a primer database to get the primer assignment for a sequence.

my $usage = "\n\tUsage: comboblast_output.pl [options: -h -d <PATH to fasta files>] -i <.comboblast file>\n\n";

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
	my ($fasta)     = $infile =~ /(\S+\.(rem\.fa|fa_1|fa_2|fa))\.*\S*\.comboblast$/;
	my ($filename)  = $fasta  =~ /(\S+)\.(rem\.fa|fa_1|fa_2|fa)$/;
	my ($extension) = $fasta  =~ /\.((rem\.fa|fa_1|fa_2|fa))$/;
	
	open PB, "<$infile" or die "\n\tError: cannot open $infile\n\n";

	while (<PB>) {
		if ($_ =~ /^Query=/) {
			my ($id) = /Query= (\S+)$/;

			until ($_ =~ /^lcl/ or $_ =~ /^\*\*\*\*\* No hits found/) {$_ = <PB>}

			if ($_ =~ /No hits found/) {
				$blast_results{$id} = ["no_hit"];
			} else {
				my ($best_match) = /lcl\|(\S+)/;
				my ($evalue)     = /((\d\.\d{1,3}|\de\-\d{2}))\s*$/;
				chomp $evalue;
				$blast_results{$id} = [$best_match, $evalue];
			}
		}
	}

	close PB;

	# my @raw_ids = keys %blast_results;
	# my @seq_nums;

	# for (@raw_ids) {
	# 	my ($seq_num) = /^(\d+):/;
	# 	push @seq_nums, $seq_num;
	# }

	# my @results_ids = @raw_ids[ sort { $seq_nums[$a] <=> $seq_nums[$b] } 0 .. $#seq_nums ];

	open FA, "<${fadir}$fasta" or die "\n\tError: cannot open ${fadir}$fasta\n\n";
	open FWD, ">${fadir}$filename.bfwd.$extension" or die "\n\tError: cannot create ${fadir}$filename.bfwd.$extension\n\n"; 
	open REV, ">${fadir}$filename.brev.$extension" or die "\n\tError: cannot create ${fadir}$filename.brev.$extension\n\n";
	open NPR, ">${fadir}$filename.bnpr.$extension" or die "\n\tError: cannot create ${fadir}$filename.bnpr.$extension\n\n";

	while (<FA>) {

		if ($_ =~ /^\>/) {
			my ($id) = /^\>(\S+)/;
			my $seq = <FA>;
			chomp $seq;
			my $primer = $blast_results{$id}[0];

			if    ($primer =~ /fwd/) {print FWD "\>$id:$primer\($blast_results{$id}[1]\)\n$seq\n"}
			elsif ($primer =~ /rev/) {print REV "\>$id:$primer\($blast_results{$id}[1]\)\n$seq\n"}
			else					 {print NPR "\>$id:$primer\n$seq\n"}
		}
	}

	close FA; close FWD; close REV; close NPR;

}









sub help_text {
	print $usage;
	print "\t\t-h: this helpful help screen\n";
	print "\t\t-d: path to directory containing blasted fasta files, default is current directory\n";
	print "\t\t-i: input file, in stand BLAST format\n\n";

}