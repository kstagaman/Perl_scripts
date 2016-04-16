#!/usr/bin/perl
# cat_primer_matched.pl
use strict; use warnings;
use Getopt::Long;

# Use this script in a directory containing multiple FASTA files that have been matched to primers using primer_check.pl

my $usage = "\n\tUsage: cat_primer_matched.pl [options: -h -d PATH] -ig <m/z> -pt <fwd/rev>\n\n";

# defaults
my $help;
my $ig;
my $ptype;
my $wdir = './';

GetOptions (
	'help!' => \$help,
	'ig=s'  => \$ig,
	'pt=s'  => \$ptype,
	'd=s'   => \$wdir,
) or die $usage;

die $usage unless $ptype and $ig or $help;
if ($wdir !~ /\/$/) {$wdir = "$wdir\/"}

if ($help) {
	help_text();
}
else {
	my @files = `ls $ig*$ptype*`;
	chomp @files;

	my ($info) = $files[1] =~ /^$ig[abcd]\d{2}\.(\S+)\.$ptype/;

	open OUT, ">all_ig$ig.$info.$ptype.fa" or die "\n\tError: cannot create all_ig$ig.$info.$ptype.fa\n\n";

	foreach my $file (@files) {
		open IN, "<$file" or die "\n\tError: cannot open $file\n\n"; 
		my ($sample) = $file =~ /^([mz][abcd]\d{2})\./;

		while (<IN>) {

			if ($_ =~ /^\>/) {
				my ($id) = $_ =~ /^\>(.+)/;
				my $seq = <IN>;
				chomp ($seq);
				print OUT "\>$sample:$id\n$seq\n";
			}
		}

		close IN;

	}

	close OUT
}

sub help_text {
	print $usage;
}